Trước khi thực hiện, chúng ta cần phải lên kế hoạch, breakdown tasks để triển khai.  Hãy định nghĩa trong memory-bank về việc thay đổi này để AI Agent quan sát và không bị quên công việc.

Một số thay đổi như sau với gem build template rails_hmvc:
1. Rails chỉ áp dụng cho môi trường development, nên không cần phân chia môi trường
2. Template áp dụng cho 2 phiên bản api và web. Nên trong file `rails_hmvc.yml` phải chỉ định các cấu hình `parent_` riêng cho từng phiên bản
3. Loại bỏ setting api_version. Vì khi tạo controller, operation, form thì người dùng sẽ nhập path cần tạo thì dựa vào path đó tạo đúng cấu trúc thư mục file. Ví dụ cho controller: `rails g rails_hmvc:controller v1/posts` thì sẽ tạo cấu trúc `V1::Posts`. Tương tự như controller
4. Trong cấu trúc generator hmvc có vẻ chưa DRY CODE. Bởi vì tạo resources  hay từng resource đơn lẻ có vẻ như đang định nghĩa template riêng biệt. Nếu sau này muốn sửa template được generate thì phải sửa nhiều file. Trong khi đó chỉ cần có 1 template chuẩn và việc tạo resources hay từng resource đơn lẻ thì sẽ dựa vào template đó.
5. Lệnh CLI mong muốn thay đổi từ `rails g rails_hmvc` thành `rails g hmvc`, nhưng tên gem thì vẫn là `rails_hmvc`. Bởi vì khi nhập CLI cảm thấy không được đẹp mắt khi trùng chữ rails
6. Trong file config `rails_hmvc.yml` thì củng có config cho từng resources operations, forms, controllers cho việc tạo ra các file endpoint và form endpoint. Mặc dù thông thường index, show sẽ ít khi cần validate. Nhưng việc cho phép người dùng setting trong cấu hình rails_hmvc.yml sẽ chuẩn hóa và mở rộng linh hoạt.
7. Khi `init` thì tôi thấy có cấu hình load rails_hmvc_config ở application.rb của dự án. Việc này cần cải thiện tải vào file `config/initialize` để clean code. Và đảm bảo khi vận hành rails thì sẽ không có lỗi
```
config.before_configuration do
  rails_hmvc_config = Rails.root.join('config', 'rails_hmvc.yml')
  if File.exist?(rails_hmvc_config)
    begin
      config_content = YAML.safe_load(File.read(rails_hmvc_config))
      config_env = config_content[Rails.env] || {}

      config_env.each do |key, value|
        config.send("#{key}=", value) if config.respond_to?("#{key}=")
      end
    rescue => e
      puts "Warning: Error loading rails_hmvc.yml: #{e.message}"
    end
  end
end
```
8. Cần bổ sung comment trong template cho các trường hợp:
- Đối với các endpoints controllers thì trên mỗi endpoint phải có comment route. Các route này sẽ được lấy dynamic từ router.rb để xác định. Ví dụ
```
# [POST] v1/users
def create; end

# [GET] v1/users
def index; end

# [DELETE] v1/users/:id
def destroy; end
```
- Đối với đầu tệp tin của operation, form thì cần có comment docstring chú thích operation, form đang sử dụng ở đâu. Theo convention thì gọi các layer này theo endpoint. Thứ tự Controller > Operation > Form. Tất nhiên sẽ có những ngoại lệ, nhưng lúc đó người dùng sẽ tự manual. Và củng không khuyến khích dev làm sai convention
9. Trong form cần có validate đối với các form nested_attributes. Vì 1 form sẽ đảm nhận 1 cấu trúc request params, nếu params bị nested nhiều thì sẽ tạo ra nhiều form và sẽ nested vào form chính. ---> Phần này tôi chưa có ý tưởng để thực hiện. Theo như convention thì Operation > Form sẽ theo endpoint của controller. Nếu nested form thì sẽ tạo ở folder, file khác. Nhưng cần có quy tắc nếu không thì sẽ mất đi bản chất convention. Như trước đây tôi tự đặt convention `concerns/` thì được dùng chung cho các form khác. Tùy vào mỗi scope của concerns ở đâu thì dùng chung ở đó. Đây là quan điểm của tôi. Nhưng nếu bạn có idea hay hơn, ràng buộc hơn thì hãy làm theo ý bạn. (nếu cần hãy xác nhận tôi trước)
9. Hướng mở rộng sau khi hoàn thiện gem build template sẽ build các template setup rspec, jwt authorize, s3, slack notify
