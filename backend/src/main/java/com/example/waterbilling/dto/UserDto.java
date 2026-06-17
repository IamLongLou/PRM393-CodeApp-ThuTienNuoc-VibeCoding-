package com.example.waterbilling.dto;

import com.example.waterbilling.entity.AppUser;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Thông tin người dùng trả về cho app sau khi đăng nhập.")
public record UserDto(
        @Schema(description = "Tên đăng nhập.", example = "admin")
        String username,
        @Schema(description = "Họ tên hiển thị.", example = "Quản Trị Viên")
        String fullName,
        @Schema(description = "Vai trò người dùng: admin, staff hoặc user.", example = "admin")
        String role,
        @Schema(description = "Email người dùng.", example = "admin@water.com")
        String email,
        @Schema(description = "Số điện thoại người dùng.", example = "0987654321")
        String phone,
        @Schema(description = "Mã khách hàng liên kết với tài khoản này.", example = "KH001")
        String customerCode
) {
    public static UserDto from(AppUser user) {
        return new UserDto(
                user.getUsername(),
                user.getFullName(),
                user.getRole().name().toLowerCase(),
                user.getEmail(),
                user.getPhone(),
                user.getCustomer() != null ? user.getCustomer().getCode() : null
        );
    }
}
