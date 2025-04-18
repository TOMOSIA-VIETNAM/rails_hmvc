# Active Context

## Current Status

Đã hoàn thành phát triển cơ bản các generator cho rails_hmvc gem. Gem đã chuyển sang mô hình "template-only" với việc không cung cấp runtime components mà chỉ cung cấp generators để tạo ra code cần thiết cho dự án Rails mới.

### Completed Components
- **Init Generator**: Khởi tạo cấu trúc HMVC cơ bản cho dự án Rails
- **Resources Generator**: Tạo đầy đủ các thành phần cho một resource (controller, operations, forms, serializer)
- **Form Generator**: Tạo form objects với attribute và validation
- **Operation Generator**: Tạo operations với custom steps
- **Controller Generator**: Tạo controllers với các actions chuẩn
- **Serializer Generator**: Tạo serializers với attributes và associations

### Current Work
- **Testing**: Cần viết tests cho tất cả các generators
- **Documentation**: Cần viết documentation chi tiết
- **Example Rails App**: Đã tạo app demo trong thư mục example/

### Next Steps
1. Hoàn thiện tests
2. Viết README.md chi tiết
3. Thêm examples và screenshots
4. Chuẩn bị gem để publish

## Important Decisions

1. **Template-Only Approach**: Không cung cấp runtime components, chỉ cung cấp generators để tạo code
2. **Namespace Change**: Đổi namespace từ `Rails::Hmvc` thành `RailsHmvc` để tránh xung đột
3. **YAML Configuration**: Sử dụng file rails_hmvc.yml để cấu hình generators
4. **Modular Design**: Thiết kế modular cho phép sử dụng từng generator riêng biệt
