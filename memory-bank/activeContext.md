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

### Code Structure
- **Main Module**: RailsHmvc module là entry point chính của gem
- **Generators Module**: Chứa tất cả các generators, mỗi generator là một class riêng
- **Templates Directory**: Mỗi generator có một thư mục templates riêng
- **Generator Helpers**: Module `GeneratorHelpers` chứa các helper methods được dùng chung

### Generator Workflow
1. **Init Generator**: Tạo cấu trúc ban đầu và các base classes
2. **Resource Generator**: Tạo đầy đủ các components cho một resource, gọi các generator con
3. **Individual Generators**: Controller, Operation, Form, Serializer có thể được gọi riêng lẻ

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

## Technical Observations
1. **Generator Structure**: Mỗi generator hiện tại có cấu trúc riêng, có thể được cải thiện để DRY hơn
2. **Template Management**: Templates được lưu trong từng thư mục generator, có thể được tập trung để dễ dàng bảo trì
3. **Configuration Logic**: Logic đọc cấu hình từ YAML đã được viết trong `GeneratorHelpers` module
4. **CLI Interface**: Cấu trúc lệnh CLI hiện tại hơi phức tạp, cần được đơn giản hóa
5. **Error Handling**: Đã có các templates cho error handling, cần cải thiện tính nhất quán

## Current Enhancement Tasks

Dựa trên yêu cầu cải thiện tính năng trong `change_request.md`, sau đây là các tasks cụ thể cần thực hiện:

### 1. Cải thiện cấu hình môi trường
- [x] **Task 1.1**: Loại bỏ phân chia môi trường, chỉ giữ lại cấu hình cho `development`
- [x] **Task 1.2**: Cập nhật `GeneratorHelpers.load_config` để không còn phụ thuộc vào Rails.env
- [x] **Task 1.3**: Cập nhật template rails_hmvc.yml để loại bỏ cấu trúc môi trường

### 2. Cải thiện cấu hình phiên bản (api & web)
- [x] **Task 2.1**: Cập nhật template rails_hmvc.yml để phân chia cấu hình theo type (api/web)
- [x] **Task 2.2**: Cập nhật `GeneratorHelpers` để đọc cấu hình theo type
- [x] **Task 2.3**: Cập nhật tất cả generators để sử dụng cấu hình theo type

### 3. Loại bỏ `api_version`
- [x] **Task 3.1**: Cập nhật template rails_hmvc.yml để loại bỏ setting api_version
- [x] **Task 3.2**: Cập nhật `GeneratorHelpers` để xử lý path-based namespace generation
- [x] **Task 3.3**: Cập nhật tất cả generators để sử dụng path-based namespace

### 4. Cải thiện Generator resources
- [x] **Task 4.1**: Cập nhật controller template để thêm comments về HTTP method và route
- [x] **Task 4.2**: Cập nhật operation template theo chuẩn mới
- [x] **Task 4.3**: Cập nhật form template theo chuẩn mới
- [ ] **Task 4.4**: Cập nhật serializer template (nếu cần)

### 5. Cấu hình resource trong YAML
- [x] **Task 5.1**: Cập nhật template rails_hmvc.yml để thêm cấu hình cho controllers, operations, forms
- [x] **Task 5.2**: Cập nhật `GeneratorHelpers` để đọc và xử lý cấu hình resource
- [x] **Task 5.3**: Cập nhật generator resources để sử dụng cấu hình resource

### 6. Cải thiện initializer
- [x] **Task 6.1**: Tạo template cho initializer rails_hmvc.rb
- [x] **Task 6.2**: Cập nhật init_generator để tạo initializer thay vì sửa application.rb
- [x] **Task 6.3**: Cập nhật logic load config trong initializer

### 7. Thêm comments
- [x] **Task 7.1**: Cập nhật controller template để thêm comments HTTP method và route
- [x] **Task 7.2**: Đảm bảo comments được thêm vào đúng định dạng

## Implementation Strategy

1. **Thứ tự thực hiện**:
   - Bắt đầu với các thay đổi cấu hình (Tasks 1, 2, 3)
   - Tiếp theo là cải thiện templates (Tasks 4, 7)
   - Cuối cùng là cấu hình resource và initializer (Tasks 5, 6)

2. **Độ ưu tiên**:
   - Cao: Tasks 1, 3, 6 (thay đổi cơ bản về cấu hình và khởi tạo)
   - Trung bình: Tasks 2, 4, 7 (cải thiện templates và comments)
   - Thấp: Task 5 (cấu hình resource trong YAML)

3. **Rủi ro**:
   - Việc thay đổi cấu trúc cấu hình có thể ảnh hưởng đến generators hiện tại
   - Thay đổi path-based namespace generation có thể ảnh hưởng đến các dự án đang sử dụng gem
   - Cần đảm bảo khả năng tương thích ngược

## Recent Progress
Đã hoàn thành gần như tất cả các tasks từ yêu cầu cải thiện:
1. Đã loại bỏ phụ thuộc vào Rails.env trong cấu hình
2. Đã cập nhật template YAML để phân chia cấu hình theo type (api/web)
3. Đã loại bỏ api_version và chuyển sang path-based namespace
4. Đã cập nhật templates cho controller, operation, form
5. Đã thêm cấu hình resource trong YAML và hỗ trợ việc đọc cấu hình này
6. Đã tạo initializer thay vì sửa application.rb
7. Đã thêm comments HTTP method và route vào controller

Còn lại công việc:
1. Cập nhật serializer template (nếu cần)
2. Tinh chỉnh kết nối giữa các components
3. Kiểm tra và test lại toàn bộ thay đổi
