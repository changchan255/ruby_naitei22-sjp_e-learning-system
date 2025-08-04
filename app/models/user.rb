class User < ApplicationRecord
  # Các khóa học do người dùng này tạo
  has_many :created_courses, class_name: 'Course', foreign_key: 'created_by'

  # Các bài học do người dùng này tạo
  has_many :created_lessons, class_name: 'Lesson', foreign_key: 'created_by'

  # Quan hệ trực tiếp tới bảng join UserCourse
  has_many :user_courses, dependent: :destroy
  # Quan hệ tới các khóa học đã đăng ký thông qua bảng join
  has_many :enrolled_courses, through: :user_courses, source: :course

  # Quan hệ tới bảng join UserLesson
  has_many :user_lessons, dependent: :destroy
  # Quan hệ tới các bài học đã học thông qua bảng join
  has_many :lessons, through: :user_lessons

  # Quan hệ tới bảng quản lý khóa học của admin
  has_many :admin_course_managers, dependent: :destroy
  # Quan hệ tới các khóa học mà user này quản lý
  has_many :managed_courses, through: :admin_course_managers, source: :course

  # Các từ vựng của người dùng
  has_many :user_words, dependent: :destroy

  # Các kết quả bài kiểm tra
  has_many :test_results, dependent: :destroy

  attr_accessor :remember_token

  has_secure_password

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  USER_PERMITTED = %i(
    name email password
    password_confirmation birthday gender
  ).freeze

  enum gender: { male: 0, female: 1, other: 2 }
  enum role: { user: 0, admin: 1 }

  validates :name,
            presence: true,
            length: {maximum: Settings.user.max_name_length}
  validates :email,
            presence: true,
            length: {maximum: Settings.user.max_email_length},
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}
  validates :birthday, presence: true
  validates :gender, presence: true

  validate :birthday_within_100_years

  class << self
    def new_token
      SecureRandom.urlsafe_base64
    end

    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost:
    end
  end

  def remember
    self.remember_token = User.new_token
    update_attribute :remember_digest, User.digest(remember_token)
  end

  def authenticated? remember_token
    return false if remember_digest.nil?

    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_column :remember_digest, nil
  end

  private

  def birthday_within_100_years
    return if birthday.blank? || !birthday.is_a?(Date)

    current_date = Time.zone.today
    hundred_years_ago = current_date.prev_year(Settings.user.hundred_years)

    if birthday < hundred_years_ago
      errors.add(:birthday, :too_old)
    elsif birthday > current_date
      errors.add(:birthday, :in_future)
    end
  end
end
