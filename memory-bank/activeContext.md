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
- **Cải tiến Generators**: Đang lên kế hoạch cho việc cải tiến cấu trúc generators và cải thiện DRY code
- **CLI Improvement**: Thay đổi lệnh CLI từ `rails g rails_hmvc` thành `rails g hmvc`
- **Configuration Improvement**: Cải thiện cấu hình trong rails_hmvc.yml
- **Documentation**: Cần viết documentation chi tiết
- **Example Rails App**: Đã tạo app demo trong thư mục example/

### Next Steps
1. Triển khai các thay đổi đã lên kế hoạch
2. Hoàn thiện tests
3. Viết README.md chi tiết
4. Chuẩn bị gem để publish

## Important Decisions

1. **Template-Only Approach**: Không cung cấp runtime components, chỉ cung cấp generators để tạo code
2. **Namespace Change**: Đổi namespace từ `Rails::Hmvc` thành `RailsHmvc` để tránh xung đột
3. **YAML Configuration**: Sử dụng file rails_hmvc.yml để cấu hình generators
4. **Modular Design**: Thiết kế modular cho phép sử dụng từng generator riêng biệt
5. **CLI Command Change**: Thay đổi từ `rails g rails_hmvc` thành `rails g hmvc` để cải thiện UX
6. **DRY Generator Templates**: Cải tiến cấu trúc để tập trung templates, giúp việc bảo trì và cập nhật dễ dàng hơn
7. **Path-based Generation**: Dựa vào path parameter để tạo cấu trúc thư mục và namespace, loại bỏ setting api_version

## Planned Changes
Đang lên kế hoạch nhiều cải tiến quan trọng cho gem, xem chi tiết trong file progress.md.
