export async function createOtp(phone: string) {
  return { phone, code: "123456" };
}
export async function validateOtp(phone: string, code: string) {
  return code === "123456";
}
