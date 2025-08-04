class Course < ApplicationRecord
  # Người dùng đã tạo khóa học này
  belongs_to :creator, class_name: 'User', foreign_key: 'created_by'

  # Các bài học thuộc khóa học này
  has_many :lessons, dependent: :destroy

  # Quan hệ tới bảng join UserCourse
  has_many :user_courses, dependent: :destroy
  # Các người dùng đã đăng ký khóa học này
  has_many :users, through: :user_courses

  # Quan hệ tới bảng quản lý khóa học của admin
  has_many :admin_course_managers, dependent: :destroy
  # Các admin quản lý khóa học này
  has_many :admins, through: :admin_course_managers, source: :user
end
