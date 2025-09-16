# frozen_string_literal: true

# This file demonstrates Rails HMVC RuboCop cops with good and bad examples

# =============================================================================
# OPERATIONS EXAMPLES
# =============================================================================

# BAD: Missing call method
class BadUserOperation < ApplicationOperation
  def execute  # Should be 'call'
    User.create!(params)
  end
end

# BAD: Direct model calls in call method
class BadCreateUserOperation < ApplicationOperation
  def call
    User.create!(params)  # Direct database call
    Product.find(1)       # Direct database call
  end
end

# BAD: No step methods
class BadProcessOrderOperation < ApplicationOperation
  def call
    order = Order.find(params[:id])
    order.status = 'processing'
    order.save!
    OrderMailer.processing_notification(order).deliver_now
  end
end

# GOOD: Proper operation structure
class GoodCreateUserOperation < ApplicationOperation
  def call
    step_validate_params
    step_create_user
    step_send_notification
  end

  private

  def step_validate_params
    # validation logic
  end

  def step_create_user
    User.create!(user_params)  # OK in step methods
  end

  def step_send_notification
    # notification logic
  end
end

# =============================================================================
# FORMS EXAMPLES
# =============================================================================

# BAD: Contains model-related methods
class BadUserForm < ApplicationForm
  scope :active, -> { where(active: true) }     # Not allowed in forms
  delegate :name, to: :user                     # Not allowed in forms
  has_one :profile                              # Not allowed in forms
  belongs_to :organization                      # Not allowed in forms

  validates :email, presence: true

  def save
    User.create!(attributes)  # Direct database interaction
  end
end

# GOOD: Only validation logic
class GoodUserForm < ApplicationForm
  attribute :email, :string
  attribute :name, :string
  attribute :age, :integer

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, length: { minimum: 2, maximum: 50 }
  validates :age, numericality: { greater_than: 0, less_than: 120 }

  def valid!
    raise ExceptionError::UnprocessableEntity, error_messages.to_json unless valid?
  end

  private

  def error_messages
    errors.messages.map { |key, value| { key => value.first } }
  end
end

# =============================================================================
# CONTROLLERS EXAMPLES
# =============================================================================

# BAD: Contains business logic
class BadUsersController < ApplicationController
  def create
    user = User.new(user_params)
    if user.email.present?
      user.name = user.name.titleize        # Business logic
      user.email = user.email.downcase      # Business logic
      user.save!
      UserMailer.welcome_email(user).deliver_now  # Business logic
      render json: user
    else
      render json: { errors: ['Email required'] }
    end
  end

  def update
    user = User.find(params[:id])
    user.update!(user_params)
    render json: user
  end
end

# GOOD: Delegates to operations
class GoodUsersController < ApplicationController
  def create
    operator = User::CreateOperation.call(params: user_params)
    if operator.success?
      render json: operator.result, status: :created
    else
      render json: { errors: operator.errors }, status: :unprocessable_entity
    end
  end

  def update
    operator = User::UpdateOperation.call(params: user_params.merge(id: params[:id]))
    if operator.success?
      render json: operator.result
    else
      render json: { errors: operator.errors }, status: :unprocessable_entity
    end
  end

  def index
    render :index  # Simple renders are OK
  end

  def show
    render :show  # Simple renders are OK
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :age)
  end
end

# =============================================================================
# MODELS EXAMPLES
# =============================================================================

# BAD: Too many complex methods (should be in concerns)
class BadUser < ApplicationRecord
  validates :email, presence: true

  # This method is too complex (> 5 lines)
  def full_name_with_title_and_formatting
    title = determine_title_based_on_age_and_status
    formatted_title = format_title_for_display(title)
    middle_initial = extract_middle_initial_if_present
    suffix = calculate_suffix_based_on_membership_status
    "#{formatted_title} #{first_name} #{middle_initial} #{last_name} #{suffix}"
  end

  # Too many custom methods in model
  def determine_title_based_on_age_and_status
    # 20+ lines of complex logic
  end

  def format_title_for_display(title)
    # 10+ lines of formatting logic
  end

  def extract_middle_initial_if_present
    # Complex logic
  end

  def calculate_suffix_based_on_membership_status
    # Complex logic
  end

  def complex_business_rule_validation
    # Complex validation logic
  end

  def another_complex_method
    # More complex logic
  end

  def yet_another_complex_method
    # Even more complex logic
  end

  def ninth_complex_method
    # Too many methods
  end

  def tenth_complex_method
    # Way too many methods
  end
end

# GOOD: Simple model with complex logic in concerns
class GoodUser < ApplicationRecord
  include UserNameFormatting
  include UserStatusManagement
  include UserValidations

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true

  scope :active, -> { where(active: true) }
  scope :recent, -> { where('created_at > ?', 1.week.ago) }

  has_one :profile, dependent: :destroy
  has_many :orders, dependent: :destroy

  enum status: { pending: 0, active: 1, inactive: 2 }

  # Simple methods are OK
  def full_name
    "#{first_name} #{last_name}"
  end

  def active?
    status == 'active'
  end

  def display_name
    full_name.presence || email
  end
end

# Complex logic moved to concerns
module UserNameFormatting
  extend ActiveSupport::Concern

  def full_name_with_title
    # Complex formatting logic here
  end

  def formatted_display_name
    # Complex display logic here
  end
end

module UserStatusManagement
  extend ActiveSupport::Concern

  def determine_status_based_on_activity
    # Complex status determination logic
  end

  def calculate_membership_level
    # Complex calculation logic
  end
end
