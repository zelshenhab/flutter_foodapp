import { supabase } from "../../../core/config/supabase";
import {
  createPayment,
  getPayment,
} from "../../../core/yookassa/yookassa.client";

import {
  awardLoyaltyPoints,
  redeemLoyaltyPoints,
} from "../loyalty/loyalty.service";

class PaymentService {
  /* ======================================================
     CREATE PAYMENT
  ====================================================== */

  async createPayment(orderId: number, userId: number) {
    const { data: order, error } = await supabase
      .from("Order")
      .select("*")
      .eq("id", orderId)
      .eq("userId", userId)
      .single();

    if (error || !order) {
      throw new Error("Order not found");
    }

    if (order.paymentStatus === "Paid") {
      throw new Error("Order is already paid");
    }

    const paymentAmount = Number(order.total);

    if (
      !Number.isFinite(paymentAmount) ||
      paymentAmount <= 0
    ) {
      throw new Error("Invalid order total");
    }

    const { data: user, error: userError } =
      await supabase
        .from("User")
        .select("email")
        .eq("id", userId)
        .single();

    if (userError || !user) {
      throw new Error("User not found");
    }

    const email = user.email || "test@example.com";

    const items = [
      {
        description: `Order #${orderId}`,
        quantity: "1.00",
        amount: {
          value: paymentAmount.toFixed(2),
          currency: "RUB",
        },
        vat_code: 1,
        payment_mode: "full_prepayment",
        payment_subject: "commodity",
      },
    ];

    const payment = await createPayment({
      amount: paymentAmount,
      orderId,
      email,
      items,
    });

    const { error: updateError } = await supabase
      .from("Order")
      .update({
        paymentStatus: "Pending",
        yookassaPaymentId: payment.id,
        paymentProvider: "yookassa",
      })
      .eq("id", orderId)
      .eq("userId", userId);

    if (updateError) {
      console.error(
        "❌ FAILED TO SAVE PAYMENT:",
        updateError
      );

      throw new Error(
        "Failed to save payment information"
      );
    }

    return {
      paymentId: payment.id,
      confirmationUrl:
        payment.confirmation.confirmation_url,
      amount: paymentAmount,
    };
  }

  /* ======================================================
     GET STATUS
  ====================================================== */

  async getPaymentStatus(paymentId: string) {
    const payment = await getPayment(paymentId);
    return payment.status as string;
  }

  /* ======================================================
     PROCESS LOYALTY
  ====================================================== */

  private async processLoyalty(order: any) {
    if (order.loyaltyProcessed === true) {
      console.log(
        `ℹ️ Loyalty already processed for order ${order.id}`
      );

      return;
    }

    /*
     * Atomically claim this order for loyalty processing.
     * Only one webhook/status request should succeed here.
     */
    const {
      data: claimedOrder,
      error: claimError,
    } = await supabase
      .from("Order")
      .update({
        loyaltyProcessed: true,
      })
      .eq("id", order.id)
      .eq("loyaltyProcessed", false)
      .select(
        "id, userId, total, pointsUsed, loyaltyProcessed"
      )
      .maybeSingle();

    if (claimError) {
      throw new Error(
        `Failed to claim loyalty processing: ${claimError.message}`
      );
    }

    /*
     * Another request has already claimed or processed it.
     */
    if (!claimedOrder) {
      console.log(
        `ℹ️ Loyalty processing already claimed for order ${order.id}`
      );

      return;
    }

    try {
      const pointsUsed = Math.max(
        0,
        Math.floor(
          Number(claimedOrder.pointsUsed ?? 0)
        )
      );

      /* -----------------------------------------
       * Deduct points used for this order
       * --------------------------------------- */

      if (pointsUsed > 0) {
        const {
          data: existingRedemption,
          error: redemptionCheckError,
        } = await supabase
          .from("LoyaltyTransaction")
          .select("id")
          .eq("userId", claimedOrder.userId)
          .eq("type", "redeemed")
          .eq("referenceid", claimedOrder.id)
          .maybeSingle();

        if (redemptionCheckError) {
          throw redemptionCheckError;
        }

        if (!existingRedemption) {
          const redemption =
            await redeemLoyaltyPoints(
              claimedOrder.userId,
              pointsUsed,
              claimedOrder.id
            );

          console.log(
            `✅ Redeemed ${pointsUsed} points for order ${claimedOrder.id}`,
            redemption
          );
        } else {
          console.log(
            `ℹ️ Points already redeemed for order ${claimedOrder.id}`
          );
        }
      }

      /* -----------------------------------------
       * Award new points for paid amount
       * --------------------------------------- */

      const {
        data: existingReward,
        error: rewardCheckError,
      } = await supabase
        .from("LoyaltyTransaction")
        .select("id")
        .eq("userId", claimedOrder.userId)
        .eq("type", "earned")
        .eq("referenceid", claimedOrder.id)
        .maybeSingle();

      if (rewardCheckError) {
        throw rewardCheckError;
      }

      if (!existingReward) {
        const reward = await awardLoyaltyPoints(
          claimedOrder.userId,
          claimedOrder.id,
          Number(claimedOrder.total)
        );

        console.log(
          `✅ Awarded ${reward.pointsEarned} points for order ${claimedOrder.id}`
        );

        if (reward.newBalance !== undefined) {
          console.log(
            `✅ New loyalty balance: ${reward.newBalance}`
          );
        }
      } else {
        console.log(
          `ℹ️ Reward already awarded for order ${claimedOrder.id}`
        );
      }

      console.log(
        `✅ Loyalty processing completed for order ${claimedOrder.id}`
      );
    } catch (loyaltyError) {
      /*
       * Allow a future webhook/status request to retry.
       */
      const { error: resetError } = await supabase
        .from("Order")
        .update({
          loyaltyProcessed: false,
        })
        .eq("id", claimedOrder.id);

      if (resetError) {
        console.error(
          "❌ FAILED TO RESET LOYALTY STATUS:",
          resetError
        );
      }

      throw loyaltyError;
    }
  }

  /* ======================================================
     SYNC ORDER WITH YOOKASSA
  ====================================================== */

  async syncOrderWithPayment(paymentId: string) {
    const payment = await getPayment(paymentId);

    const { data: order, error } = await supabase
      .from("Order")
      .select("*")
      .eq("yookassaPaymentId", paymentId)
      .single();

    if (error || !order) {
      throw new Error(
        "Order not found for payment"
      );
    }

    if (payment.status === "succeeded") {
      const { error: paidUpdateError } =
        await supabase
          .from("Order")
          .update({
            paymentStatus: "Paid",
            paidAt:
              order.paidAt ??
              new Date().toISOString(),
            status:
              order.status === "completed"
                ? order.status
                : "pending",
          })
          .eq("id", order.id);

      if (paidUpdateError) {
        console.error(
          "❌ FAILED TO MARK ORDER PAID:",
          paidUpdateError
        );

        throw new Error(
          "Failed to update paid order"
        );
      }

      try {
        await this.processLoyalty(order);
      } catch (loyaltyError) {
        /*
         * Payment has succeeded, so do not change it back
         * to Pending if loyalty processing fails.
         */
        console.error(
          "❌ LOYALTY PROCESSING ERROR:",
          loyaltyError
        );
      }
    } else if (payment.status === "canceled") {
      const { error: cancelledUpdateError } =
        await supabase
          .from("Order")
          .update({
            paymentStatus: "Cancelled",
          })
          .eq("id", order.id);

      if (cancelledUpdateError) {
        console.error(
          "❌ FAILED TO CANCEL ORDER PAYMENT:",
          cancelledUpdateError
        );
      }
    } else {
      const { error: pendingUpdateError } =
        await supabase
          .from("Order")
          .update({
            paymentStatus: "Pending",
          })
          .eq("id", order.id);

      if (pendingUpdateError) {
        console.error(
          "❌ FAILED TO UPDATE PENDING PAYMENT:",
          pendingUpdateError
        );
      }
    }

    return payment.status as string;
  }

  /* ======================================================
     WEBHOOK COMPATIBILITY
  ====================================================== */

  async markOrderPaid(paymentId: string) {
    /*
     * Do not maintain a second payment-success flow here.
     * Always verify the current status with YooKassa.
     */
    return this.syncOrderWithPayment(paymentId);
  }
}

export const paymentService =
  new PaymentService();