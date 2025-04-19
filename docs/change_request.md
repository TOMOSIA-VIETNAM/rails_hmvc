**Xác nhận Change Request**
1. **Điều quan trọng nhất:** Giữ lại mọi tính năng hiện có, chỉ thực hiện các yêu cầu cải thiện, không tái thiết kế toàn bộ.
2. **Các tính năng hiện có được giữ nguyên:**
   - Tạo đơn lẻ generator: controller, form, operation, serializer.
   - Cấu trúc cơ bản của gem và các tính năng khác không đề cập.
3. **Những cải thiện yêu cầu:**
   a) Môi trường: chỉ `development`.
   b) Cấu hình api & web: `parent_*` riêng.
   c) Loại bỏ `api_version`, dùng path để xác định namespace.
   d) Cải tiến generator: thêm comment HTTP method & route; tạo operation, form chuẩn.
   e) Cấu hình resource trong YAML: actions, skip_actions.
   f) Cải thiện initializer.
   g) Thêm comment & docstring rõ ràng.

**1. Môi trường**
- Chỉ áp dụng cho `development`. Loại bỏ mọi phân chia môi trường khác.

**2. Phiên bản (api & web)**
- Trong file `config/rails_hmvc.yml`, định nghĩa riêng `parent_*` cho mỗi phiên bản:
  ```yaml
  api:
    parent_controller: MainController
    parent_operation: MainOperation
    parent_form: MainForm
    parent_serializer: MainSerializer

  web:
    parent_controller: MainController
    parent_operation: MainOperation
    parent_form: MainForm
    parent_serializer: MainSerializer
  ```
- Khi generate, gem sẽ chọn cấu hình tương ứng (api hoặc web).

**3. Loại bỏ `api_version`**
- Không còn setting `api_version` trong config.
- Thư mục và namespace được sinh dựa trực tiếp vào `path` người dùng nhập khi chạy generator.

**4. Generator & Cấu trúc thư mục**

4.1 **Controller**
- Lệnh: `rails g rails_hmvc:controller namespace/name [--actions=index,show,...]`
- Tạo file: `app/controllers/namespace/name_controller.rb` với nội dung:
  ```ruby
  class Namespace::NameController < MainController
    # [GET]    /namespace/name
    def index; end

    # [GET]    /namespace/name/:id
    def show; end

    # [POST]   /namespace/name
    def create; end

    # [PUT]    /namespace/name/:id
    def update; end

    # [DELETE] /namespace/name/:id
    def destroy; end
  end
  ```

4.2 **Operation**
- Với mỗi action, tạo class kế thừa `MainOperation` tại:
  `app/operations/namespace/name/<action>_operation.rb`
- Ví dụ:
  ```ruby
  class Namespace::Name::IndexOperation < MainOperation
    def call; end
  end
  ```

4.3 **Form**
- Với mỗi operation, tạo class kế thừa `MainForm` tại:
  `app/forms/namespace/name/<action>_form.rb`
- Ví dụ:
  ```ruby
  class Namespace::Name::IndexForm < MainForm
  end
  ```

**5. Cấu hình resource trong `rails_hmvc.yml`**
- Cho phép định nghĩa các option cho `controllers`, `operations`, `forms`, `serializers` để customize việc generate.
- Ví dụ:
  ```yaml
  api:
    controllers:
      actions: [index, show, create]
    operations:
      actions: [index, show, create]
    forms:
      actions: [index, show, create]
      skip_actions: [index, show]
  ```
- Mục đích: chuẩn hóa và mở rộng linh hoạt.

**6. Cải thiện initializer**
- Di chuyển logic load config từ `application.rb` vào `config/initializers/rails_hmvc.rb`:
  ```ruby
  rails_hmvc_config = Rails.root.join('config', 'rails_hmvc.yml')
  if File.exist?(rails_hmvc_config)
    config_data = YAML.safe_load(File.read(rails_hmvc_config))
    (config_data[Rails.env] || {}).each do |key, value|
      Rails.configuration.send("#{key}=", value) if Rails.configuration.respond_to?("#{key}=")
    end
  end
  ```

**7. Comment & Docstring**
- **Controller**: trước mỗi action comment rõ HTTP method và route tương ứng (lấy từ `routes.rb`).
  ```ruby
  # [POST] /v1/users
  def create; end
  ```
