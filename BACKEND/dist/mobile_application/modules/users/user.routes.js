"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.userRouter = void 0;
const express_1 = require("express");
const user_controller_1 = require("./user.controller");
exports.userRouter = (0, express_1.Router)();
// Auth required on /me & avatar
exports.userRouter.get("/me", user_controller_1.getMe);
exports.userRouter.put("/me", user_controller_1.updateMe);
/*userRouter.put("/me/avatar", putAvatarUrl);

// Public profile by id (if you want it public; otherwise protect)
userRouter.get("/:id", getById);*/
//# sourceMappingURL=user.routes.js.map