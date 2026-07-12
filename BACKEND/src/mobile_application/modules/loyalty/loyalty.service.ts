import { supabase } from "../../../core/config/supabase";

/* ======================================================
   GET LOYALTY INFORMATION
====================================================== */

export async function getUserLoyalty(userId: number) {
  const { data: user, error: userError } = await supabase
    .from("User")
    .select(
      "loyaltyPoints, totalPointsEarned, totalPointsRedeemed"
    )
    .eq("id", userId)
    .single();

  if (userError || !user) {
    throw {
      status: 500,
      message: "Failed to fetch loyalty points",
    };
  }

  const { data: settings, error: settingsError } =
    await supabase
      .from("LoyaltySettings")
      .select("*")
      .limit(1)
      .maybeSingle();

  if (settingsError) {
    console.error(
      "Failed to fetch loyalty settings:",
      settingsError
    );
  }

  const {
    data: transactions,
    error: transactionsError,
  } = await supabase
    .from("LoyaltyTransaction")
    .select("*")
    .eq("userId", userId)
    .order("createdAt", { ascending: false })
    .limit(20);

  if (transactionsError) {
    console.error(
      "Failed to fetch loyalty transactions:",
      transactionsError
    );
  }

  const normalizedSettings = {
    pointsPerThousand: Number(
      settings?.pointsperthousand ?? 50
    ),
    minRedeemPoints: Number(
      settings?.minredeempoints ?? 100
    ),
    maxRedeemPercent: Number(
      settings?.maxredeempercent ?? 30
    ),
  };

  return {
    points: Number(user.loyaltyPoints ?? 0),
    totalEarned: Number(
      user.totalPointsEarned ?? 0
    ),
    totalRedeemed: Number(
      user.totalPointsRedeemed ?? 0
    ),
    settings: normalizedSettings,
    transactions: transactions ?? [],
  };
}

/* ======================================================
   CALCULATE EARNED POINTS
====================================================== */

export function calculatePointsEarned(
  orderTotal: number,
  pointsPerThousand: number = 50
): number {
  return Math.floor(
    (Number(orderTotal) / 1000) *
      Number(pointsPerThousand)
  );
}

/* ======================================================
   AWARD POINTS AFTER SUCCESSFUL PAYMENT
====================================================== */

export async function awardLoyaltyPoints(
  userId: number,
  orderId: number,
  orderTotal: number
) {
  const { data: settings, error: settingsError } =
    await supabase
      .from("LoyaltySettings")
      .select("pointsperthousand")
      .limit(1)
      .maybeSingle();

  if (settingsError) {
    console.error(
      "Failed to fetch loyalty settings:",
      settingsError
    );
  }

  const pointsPerThousand = Number(
    settings?.pointsperthousand ?? 50
  );

  const pointsEarned = calculatePointsEarned(
    Number(orderTotal),
    pointsPerThousand
  );

  if (pointsEarned <= 0) {
    return {
      pointsEarned: 0,
    };
  }

  // Prevent awarding points twice for the same order.
  const {
    data: existingReward,
    error: existingRewardError,
  } = await supabase
    .from("LoyaltyTransaction")
    .select("id")
    .eq("userId", userId)
    .eq("type", "earned")
    .eq("referenceid", orderId)
    .maybeSingle();

  if (existingRewardError) {
    throw {
      status: 500,
      message:
        "Failed to check existing loyalty reward",
    };
  }

  if (existingReward) {
    console.log(
      `Loyalty reward already exists for order ${orderId}`
    );

    return {
      pointsEarned: 0,
      alreadyAwarded: true,
    };
  }

  const { data: user, error: userError } =
    await supabase
      .from("User")
      .select(
        "loyaltyPoints, totalPointsEarned"
      )
      .eq("id", userId)
      .single();

  if (userError || !user) {
    throw {
      status: 500,
      message: "Failed to fetch user",
    };
  }

  const currentBalance = Number(
    user.loyaltyPoints ?? 0
  );

  const currentTotalEarned = Number(
    user.totalPointsEarned ?? 0
  );

  const newBalance =
    currentBalance + pointsEarned;

  const newTotalEarned =
    currentTotalEarned + pointsEarned;

  const { error: updateError } = await supabase
    .from("User")
    .update({
      loyaltyPoints: newBalance,
      totalPointsEarned: newTotalEarned,
    })
    .eq("id", userId);

  if (updateError) {
    throw {
      status: 500,
      message: "Failed to award loyalty points",
    };
  }

  const { error: transactionError } =
    await supabase
      .from("LoyaltyTransaction")
      .insert({
        userId,
        points: pointsEarned,
        type: "earned",
        referenceid: orderId,
        description:
          `Earned ${pointsEarned} points from order #${orderId}`,
      });

  if (transactionError) {
    console.error(
      "Failed to record loyalty reward:",
      transactionError
    );

    throw {
      status: 500,
      message:
        "Failed to record loyalty reward",
    };
  }

  return {
    pointsEarned,
    newBalance,
  };
}

/* ======================================================
   WELCOME BONUS
====================================================== */

export async function awardWelcomeBonus(
  userId: number
) {
  const welcomePoints = 100;

  console.log(
    `🎁 Awarding ${welcomePoints} welcome points to user ${userId}...`
  );

  try {
    const {
      data: existingBonus,
      error: existingBonusError,
    } = await supabase
      .from("LoyaltyTransaction")
      .select("id")
      .eq("userId", userId)
      .eq("type", "welcome")
      .maybeSingle();

    if (existingBonusError) {
      throw existingBonusError;
    }

    if (existingBonus) {
      console.log(
        `User ${userId} already received the welcome bonus`
      );

      return {
        pointsEarned: 0,
        alreadyAwarded: true,
      };
    }

    const { data: user, error: userError } =
      await supabase
        .from("User")
        .select(
          "loyaltyPoints, totalPointsEarned"
        )
        .eq("id", userId)
        .single();

    if (userError || !user) {
      throw {
        status: 500,
        message: "Failed to fetch user",
      };
    }

    const currentPoints = Number(
      user.loyaltyPoints ?? 0
    );

    const currentTotalEarned = Number(
      user.totalPointsEarned ?? 0
    );

    const newBalance =
      currentPoints + welcomePoints;

    const newTotalEarned =
      currentTotalEarned + welcomePoints;

    const { error: updateError } =
      await supabase
        .from("User")
        .update({
          loyaltyPoints: newBalance,
          totalPointsEarned: newTotalEarned,
        })
        .eq("id", userId);

    if (updateError) {
      throw {
        status: 500,
        message:
          "Failed to award welcome bonus",
      };
    }

    const { error: transactionError } =
      await supabase
        .from("LoyaltyTransaction")
        .insert({
          userId,
          points: welcomePoints,
          type: "welcome",
          description:
            `Welcome bonus: ${welcomePoints} points`,
          createdAt: new Date().toISOString(),
        });

    if (transactionError) {
      throw {
        status: 500,
        message:
          "Failed to record welcome bonus",
      };
    }

    console.log(
      `✅ Awarded ${welcomePoints} welcome points to user ${userId}`
    );

    return {
      pointsEarned: welcomePoints,
      newBalance,
      success: true,
    };
  } catch (error) {
    console.error(
      "❌ Unexpected error in awardWelcomeBonus:",
      error
    );

    return {
      pointsEarned: 0,
      error: String(error),
    };
  }
}

/* ======================================================
   CALCULATE POINTS REDEMPTION
====================================================== */

export async function calculatePointsRedemption(
  cartTotal: number,
  requestedPoints: number,
  userId: number
) {
  const safeCartTotal = Math.max(
    0,
    Number(cartTotal ?? 0)
  );

  const safeRequestedPoints = Math.max(
    0,
    Math.floor(Number(requestedPoints ?? 0))
  );

  const { data: user, error: userError } =
    await supabase
      .from("User")
      .select("loyaltyPoints")
      .eq("id", userId)
      .single();

  if (userError || !user) {
    throw {
      status: 500,
      message:
        "Failed to fetch user loyalty balance",
    };
  }

  const { data: settings, error: settingsError } =
    await supabase
      .from("LoyaltySettings")
      .select(
        "minredeempoints, maxredeempercent"
      )
      .limit(1)
      .maybeSingle();

  if (settingsError) {
    console.error(
      "Failed to fetch loyalty settings:",
      settingsError
    );
  }

  const availablePoints = Math.max(
    0,
    Number(user.loyaltyPoints ?? 0)
  );

  const minRedeem = Number(
    settings?.minredeempoints ?? 100
  );

  const maxRedeemPercent = Number(
    settings?.maxredeempercent ?? 30
  );

  const maxPointsByOrder = Math.floor(
    (safeCartTotal * maxRedeemPercent) / 100
  );

  let maxRedeemablePoints = Math.min(
    availablePoints,
    maxPointsByOrder
  );

  maxRedeemablePoints =
    Math.floor(maxRedeemablePoints / 100) *
    100;

  let pointsToRedeem = Math.min(
    safeRequestedPoints,
    maxRedeemablePoints
  );

  pointsToRedeem =
    Math.floor(pointsToRedeem / 100) * 100;

  if (
    pointsToRedeem > 0 &&
    pointsToRedeem < minRedeem
  ) {
    pointsToRedeem = 0;
  }

  return {
    availablePoints,
    requestedPoints: safeRequestedPoints,
    appliedPoints: pointsToRedeem,
    discountAmount: pointsToRedeem,
    minRedeem,
    maxRedeemPercent,
    maxPossiblePoints: maxRedeemablePoints,
  };
}

/* ======================================================
   REDEEM POINTS AFTER SUCCESSFUL PAYMENT
====================================================== */

export async function redeemLoyaltyPoints(
  userId: number,
  pointsToRedeem: number,
  orderId?: number
) {
  const safePoints = Math.max(
    0,
    Math.floor(Number(pointsToRedeem))
  );

  if (safePoints <= 0) {
    throw {
      status: 400,
      message: "Invalid loyalty points amount",
    };
  }

  // Prevent deducting points twice for the same order.
  if (orderId) {
    const {
      data: existingRedemption,
      error: existingRedemptionError,
    } = await supabase
      .from("LoyaltyTransaction")
      .select("id")
      .eq("userId", userId)
      .eq("type", "redeemed")
      .eq("referenceid", orderId)
      .maybeSingle();

    if (existingRedemptionError) {
      throw {
        status: 500,
        message:
          "Failed to check points redemption",
      };
    }

    if (existingRedemption) {
      console.log(
        `Points already redeemed for order ${orderId}`
      );

      return {
        redeemedPoints: 0,
        alreadyRedeemed: true,
      };
    }
  }

  const { data: user, error: userError } =
    await supabase
      .from("User")
      .select(
        "loyaltyPoints, totalPointsRedeemed"
      )
      .eq("id", userId)
      .single();

  if (userError || !user) {
    throw {
      status: 500,
      message: "Failed to fetch user",
    };
  }

  const currentPoints = Number(
    user.loyaltyPoints ?? 0
  );

  if (safePoints > currentPoints) {
    throw {
      status: 400,
      message: "Insufficient loyalty points",
    };
  }

  const newBalance =
    currentPoints - safePoints;

  const newTotalRedeemed =
    Number(user.totalPointsRedeemed ?? 0) +
    safePoints;

  const { error: updateError } = await supabase
    .from("User")
    .update({
      loyaltyPoints: newBalance,
      totalPointsRedeemed:
        newTotalRedeemed,
    })
    .eq("id", userId);

  if (updateError) {
    throw {
      status: 500,
      message: "Failed to redeem points",
    };
  }

  const { error: transactionError } =
    await supabase
      .from("LoyaltyTransaction")
      .insert({
        userId,
        points: -safePoints,
        type: "redeemed",
        referenceid: orderId ?? null,
        description: orderId
          ? `Redeemed ${safePoints} points for order #${orderId}`
          : `Redeemed ${safePoints} points`,
      });

  if (transactionError) {
    console.error(
      "Failed to record redemption:",
      transactionError
    );

    throw {
      status: 500,
      message:
        "Failed to record points redemption",
    };
  }

  return {
    redeemedPoints: safePoints,
    discountAmount: safePoints,
    newBalance,
  };
}