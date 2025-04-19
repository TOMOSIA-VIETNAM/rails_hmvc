# Product Context

## Problem Statement

Rails là framework tuyệt vời nhưng cần một cấu trúc nhất quán để làm việc hiệu quả với các dự án lớn. Cấu trúc MVC chuẩn của Rails không đủ để tách biệt các concerns khi ứng dụng phát triển. Các controllers thường trở nên cồng kềnh với quá nhiều business logic, làm cho code khó bảo trì và test.

## Solution

Rails HMVC Gem đưa ra một giải pháp bằng cách cung cấp các generators để thiết lập cấu trúc HMVC (Hierarchical Model-View-Controller) trong Rails. Nó tách biệt rõ ràng các concerns:

1. **Controllers**: Xử lý HTTP requests, routing và responses
2. **Forms**: Xử lý validation và data transformation
3. **Operations**: Xử lý business logic
4. **Serializers**: Xử lý data serialization
5. **Models**: Xử lý persistence và data relationships

## User Experience

### Developer Experience

- **Tạo Code Nhanh Chóng**: Generators giúp tạo ra code mẫu tuân thủ cấu trúc HMVC
- **Cấu Trúc Nhất Quán**: Các components được tổ chức theo cấu trúc chuẩn
- **Dễ Test**: Tách biệt concerns giúp viết tests dễ dàng hơn
- **Mở Rộng Dễ Dàng**: Cấu trúc modular giúp dễ dàng thêm tính năng mới

### End User Experience

- **API Responses Nhất Quán**: Format JSON chuẩn cho responses
- **Xử Lý Lỗi Tốt Hơn**: Error handling được chuẩn hóa
- **Hiệu Năng Tốt**: Tách biệt concerns giúp tối ưu hóa từng thành phần

## Target Users

- Rails developers làm việc với các dự án API
- Teams cần một cấu trúc nhất quán cho dự án
- Developers muốn áp dụng best practices từ đầu dự án

## Value Proposition

Rails HMVC Gem giúp các teams:
1. **Tiết Kiệm Thời Gian**: Không cần tự setup cấu trúc HMVC
2. **Chuẩn Hóa Code**: Đảm bảo tất cả developers tuân thủ cùng một pattern
3. **Dễ Dàng Onboarding**: Developers mới dễ dàng hiểu cấu trúc dự án
4. **Code Chất Lượng Cao**: Khuyến khích separation of concerns và clean code
