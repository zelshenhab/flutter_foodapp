// backend/src/modules/loyalty/loyalty.service.ts
import { supabase } from "../../../core/config/supabase";

export async function getUserLoyalty(userId: number) {
  const { data: user, error } = await supabase
    .from("User")
    .select("loyaltyPoints, totalPointsEarned, totalPointsRedeemed")
    .eq("id", userId)
    .single();

  if (error) {
    throw { status: 500, message: "Failed to fetch loyalty points" };
  }

  // Get loyalty settings
  const { data: settings } = await supabase
    .from("LoyaltySettings")
    .select("*")
    .single();

  // Get recent transactions
  const { data: transactions } = await supabase
    .from("LoyaltyTransaction")
    .select("*")
    .eq("userId", userId)
    .order("createdAt", { ascending: false })
    .limit(20);

  return {
    points: user?.loyaltyPoints || 0,
    totalEarned: user?.totalPointsEarned || 0,
    totalRedeemed: user?.totalPointsRedeemed || 0,
    settings: settings || { pointsPerThousand: 50, minRedeemPoints: 100, maxRedeemPercent: 30 },
    transactions: transactions || [],
  };
}

// Calculate points earned from an order
export function calculatePointsEarned(orderTotal: number, pointsPerThousand: number = 50): number {
  // 50 points per 1000 RUB
  const points = Math.floor((orderTotal / 1000) * pointsPerThousand);
  return points;
}

// Award points to user after order completion
export async function awardLoyaltyPoints(userId: number, orderId: number, orderTotal: number) {
  // Get loyalty settings
  const { data: settings } = await supabase
    .from("LoyaltySettings")
    .select("*")
    .single();

  const pointsPerThousand = settings?.pointsPerThousand || 50;
  const pointsEarned = calculatePointsEarned(orderTotal, pointsPerThousand);

  if (pointsEarned <= 0) return { pointsEarned: 0 };

  // Get current user points
  const { data: user, error: userError } = await supabase
    .from("User")
    .select("loyaltyPoints, totalPointsEarned")
    .eq("id", userId)
    .single();

  if (userError) {
    console.error("Failed to fetch user:", userError);
    return { pointsEarned: 0 };
  }

  const newBalance = (user.loyaltyPoints || 0) + pointsEarned;
  const newTotalEarned = (user.totalPointsEarned || 0) + pointsEarned;

  // Update user points
  const { error: updateError } = await supabase
    .from("User")
    .update({
      loyaltyPoints: newBalance,
      totalPointsEarned: newTotalEarned,
    })
    .eq("id", userId);

  if (updateError) {
    console.error("Failed to update loyalty points:", updateError);
    return { pointsEarned: 0 };
  }

  // Record transaction
  const { error: transactionError } = await supabase
    .from("LoyaltyTransaction")
    .insert({
      userId,
      points: pointsEarned,
      type: "earned",
      referenceId: orderId,
      description: `Earned ${pointsEarned} points from order #${orderId} (${orderTotal} RUB)`,
    });

  if (transactionError) {
    console.error("Failed to record loyalty transaction:", transactionError);
  }

  return { pointsEarned, newBalance };
}

// backend/src/modules/loyalty/loyalty.service.ts

// Give welcome bonus to new user - FIXED VERSION
export async function awardWelcomeBonus(userId: number) {
  const welcomePoints = 100;
  
  console.log(`🎁 Awarding ${welcomePoints} welcome points to user ${userId}...`);

  try {
    // First, check if user already has a welcome bonus
    const { data: existingBonus } = await supabase
      .from("LoyaltyTransaction")
      .select("*")
      .eq("userId", userId)
      .eq("type", "welcome")
      .maybeSingle();

    if (existingBonus) {
      console.log(`⚠️ User ${userId} already received welcome bonus`);
      return { pointsEarned: 0, alreadyAwarded: true };
    }

    // Get current user points
    const { data: user, error: userError } = await supabase
      .from("User")
      .select("loyaltyPoints, totalPointsEarned")
      .eq("id", userId)
      .single();

    if (userError) {
      console.error("❌ Failed to fetch user:", userError);
      return { pointsEarned: 0, error: userError.message };
    }

    const currentPoints = user?.loyaltyPoints || 0;
    const newBalance = currentPoints + welcomePoints;
    const newTotalEarned = (user?.totalPointsEarned || 0) + welcomePoints;

    console.log(`📊 User ${userId}: current=${currentPoints}, new=${newBalance}`);

    // Update user points
    const { error: updateError } = await supabase
      .from("User")
      .update({
        loyaltyPoints: newBalance,
        totalPointsEarned: newTotalEarned,
      })
      .eq("id", userId);

    if (updateError) {
      console.error("❌ Failed to update user points:", updateError);
      return { pointsEarned: 0, error: updateError.message };
    }

    // Verify the update worked
    const { data: verifyUser } = await supabase
      .from("User")
      .select("loyaltyPoints")
      .eq("id", userId)
      .single();
    
    console.log(`✅ Verification - User ${userId} now has ${verifyUser?.loyaltyPoints} points`);

    // Record transaction
    const { error: transactionError } = await supabase
      .from("LoyaltyTransaction")
      .insert({
        userId,
        points: welcomePoints,
        type: "welcome",
        description: `Welcome bonus: ${welcomePoints} points`,
        createdAt: new Date().toISOString(),
      });

    if (transactionError) {
      console.error("❌ Failed to record transaction:", transactionError);
    } else {
      console.log(`✅ Welcome bonus transaction recorded for user ${userId}`);
    }

    console.log(`✅ Successfully awarded ${welcomePoints} welcome points to user ${userId}`);
    return { pointsEarned: welcomePoints, newBalance, success: true };
    
  } catch (error) {
    console.error("❌ Unexpected error in awardWelcomeBonus:", error);
    return { pointsEarned: 0, error: String(error) };
  }
}

// Calculate possible redemption
export async function calculatePointsRedemption(
  cartTotal: number,
  requestedPoints: number,
  userId: number
) {
  const { data: user } = await supabase
    .from("User")
    .select("loyaltyPoints")
    .eq("id", userId)
    .single();

  const { data: settings } = await supabase
    .from("LoyaltySettings")
    .select("*")
    .single();

  const availablePoints = user?.loyaltyPoints || 0;
  const minRedeem = settings?.minRedeemPoints || 100;
  const maxRedeemPercent = settings?.maxRedeemPercent || 30;
  
  // Max points based on cart total (30% of order)
  const maxPointsByOrder = Math.floor((cartTotal * maxRedeemPercent) / 100);
  
  // Max points based on user balance and order limit
  let maxRedeemablePoints = Math.min(availablePoints, maxPointsByOrder);
  
  // Round down to nearest 100 (since 1 point = 1 RUB, and we want clean numbers)
  maxRedeemablePoints = Math.floor(maxRedeemablePoints / 100) * 100;
  
  // Calculate actual points to redeem
  let pointsToRedeem = 0;
  if (requestedPoints && requestedPoints > 0) {
    pointsToRedeem = Math.min(requestedPoints, maxRedeemablePoints);
    if (pointsToRedeem < minRedeem && pointsToRedeem > 0) {
      pointsToRedeem = 0; // Can't redeem less than minimum
    }
  }
  
  const discountAmount = pointsToRedeem; // 1 point = 1 RUB
  
  return {
    availablePoints,
    requestedPoints: requestedPoints || 0,
    appliedPoints: pointsToRedeem,
    discountAmount,
    minRedeem,
    maxRedeemPercent,
    maxPossiblePoints: maxRedeemablePoints,
  };
}

// Redeem points for order
export async function redeemLoyaltyPoints(
  userId: number,
  pointsToRedeem: number,
  orderId?: number
) {
  // First calculate if redemption is valid
  // Note: We need cart total here, but for simplicity, we'll validate in cart service
  
  const { data: user, error: userError } = await supabase
    .from("User")
    .select("loyaltyPoints, totalPointsRedeemed")
    .eq("id", userId)
    .single();

  if (userError) {
    throw { status: 500, message: "Failed to fetch user" };
  }

  const currentPoints = user.loyaltyPoints || 0;

  if (pointsToRedeem > currentPoints) {
    throw { status: 400, message: "Insufficient loyalty points" };
  }

  const newBalance = currentPoints - pointsToRedeem;
  const newTotalRedeemed = (user.totalPointsRedeemed || 0) + pointsToRedeem;

  // Update user points
  const { error: updateError } = await supabase
    .from("User")
    .update({
      loyaltyPoints: newBalance,
      totalPointsRedeemed: newTotalRedeemed,
    })
    .eq("id", userId);

  if (updateError) {
    throw { status: 500, message: "Failed to redeem points" };
  }

  // Record transaction
  const { error: transactionError } = await supabase
    .from("LoyaltyTransaction")
    .insert({
      userId,
      points: -pointsToRedeem, // Negative for redemption
      type: "redeemed",
      referenceId: orderId,
      description: `Redeemed ${pointsToRedeem} points for order #${orderId || "cart"}`,
    });

  if (transactionError) {
    console.error("Failed to record redemption:", transactionError);
  }

  return {
    redeemedPoints: pointsToRedeem,
    discountAmount: pointsToRedeem,
    newBalance,
  };
}