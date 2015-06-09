require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  def setup
    @user = users(:filipexavierpavan)
    # This code is not idiomatically correct.
    @microposts = Micropost.new(content: "Hello", user_id: @user.id)
  end
  
  test "should be valid" do
    assert @microposts.valid?
  end
  
  test "user is should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end
  
end
