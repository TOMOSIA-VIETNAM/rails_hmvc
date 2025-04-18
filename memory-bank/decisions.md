# Architectural and Implementation Decisions

## Core Architecture Decisions

### 1. Template-Based Generator Approach
- **Decision**: Sử dụng chỉ template-based generators thay vì cung cấp runtime classes
- **Rationale**:
  - Tránh xung đột namespace với Rails
  - Không can thiệp vào runtime của ứng dụng Rails
  - Cho phép dự án có thể tùy chỉnh mã nguồn sau khi generate
- **Impact**:
  - Gem cung cấp chỉ các generators mà không cần runtime dependencies
  - Dễ dàng tùy chỉnh và mở rộng

### 2. HMVC Structure
- **Decision**: Tổ chức theo cấu trúc Hierarchical MVC rõ ràng
- **Rationale**:
  - Tách biệt rõ ràng các thành phần
  - Cải thiện khả năng mở rộng
  - Các thành phần có thể được thay thế riêng lẻ
- **Components**:
  - Controllers: Xử lý HTTP requests và responses
  - Forms: Xử lý validation và data transformation
  - Operations: Xử lý business logic
  - Serializers: Xử lý data serialization

### 3. Versioning Approach
- **Decision**: Sử dụng versioning thông qua namespaces
- **Rationale**:
  - Cho phép nhiều phiên bản API tồn tại cùng lúc
  - Dễ dàng mở rộng và thêm phiên bản mới
- **Implementation**:
  - Các thành phần được tổ chức trong các namespace V1, V2, ...
  - Đường dẫn URL bao gồm version (/v1, /v2)

### 4. Error Handling
- **Decision**: Xử lý lỗi tập trung thông qua Errorable concern
- **Rationale**:
  - Đồng nhất cách xử lý lỗi
  - Cải thiện UX bằng cách cung cấp thông báo lỗi rõ ràng
- **Implementation**:
  - ResourceError for resource-specific errors
  - APIError for API-level errors
  - BaseError for generic errors

## Implementation Details

### 1. Generator Structure
- **Modular Generators**:
  - Mỗi generator có thể được sử dụng độc lập
  - Các generators có thể gọi lẫn nhau để tạo ra các components đầy đủ

- **Configuration Integration**:
  - Sử dụng rails_hmvc.yml để lưu trữ cấu hình
  - CLI options có thể ghi đè cấu hình từ file
  - Mỗi generator đều đọc cấu hình từ file này

- **Template-Based Generation**:
  - Mỗi component được sinh ra từ templates riêng biệt
  - Templates có thể được tùy chỉnh dễ dàng
  - ERB được sử dụng cho templates

### 2. Response Format
- **Standard Success Response**:
  ```json
  {
    "data": [ ... ],
    "meta": { ... },
    "status": "ok"
  }
  ```
- **Standard Error Response**:
  ```json
  {
    "error": "...",
    "message": "...",
    "errors": [ ... ],
    "status": "error"
  }
  ```

### 3. Component Guidelines
- **Controllers**:
  - Xử lý HTTP requests
  - Gọi operations cho business logic
  - Render responses sử dụng serializers

- **Forms**:
  - Validate input data
  - Transform data trước khi xử lý
  - Raise errors nếu validation thất bại

- **Operations**:
  - Xử lý business logic
  - Chia nhỏ logic thành các steps
  - Giao tiếp với database và external services

- **Serializers**:
  - Format data cho responses
  - Quản lý associations
  - Xử lý data transformation

## Future Considerations

### 1. Testing Support
- **Decision**: Thêm test templates và helpers
- **Rationale**: Giúp người dùng dễ dàng viết tests cho HMVC components
- **Planned Implementation**:
  - RSpec helpers
  - Test templates cho mỗi component
  - Integration test examples

### 2. Documentation Improvement
- **Decision**: Cung cấp documentation đầy đủ
- **Rationale**: Giúp người dùng hiểu và sử dụng gem hiệu quả
- **Planned Implementation**:
  - README.md comprehensive
  - Wiki pages for detailed guides
  - Examples for common use cases

### 3. CI/CD Implementation
- **Decision**: Thêm CI/CD workflows
- **Rationale**: Đảm bảo chất lượng code
- **Planned Implementation**:
  - GitHub Actions for testing
  - Automatic releases
  - Code quality checks
