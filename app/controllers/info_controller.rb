class InfoController < ApplicationController

  layout 'info'

  before_action :authenticate_user!, only: [:new_login, :new_signup]

  def home
  end

  def experiments
  end

  def help
  end

  def test
  end

  def chart
  end

  def new_login
    redirect_to "/info/home"
  end

  def new_signup
    redirect_to "/info/home"
  end

  def data
    render plain: File.read("#{File.dirname(__FILE__)}/data.text")
  end

  def mailpost
    @address = save_address(params["mail_addr"])
    flash[:notice] = " Thanks for joining the Bugmark mailing list! (#{@address})"
    redirect_to "/info/home"
  end

  private

  def save_address(addr)
    addr_file = Rails.root.join("log", "mail_#{Rails.env}.txt").to_s
    tstamp    = BugmTime.now.strftime("%Y-%m-%d_%H:%M:%S")
    File.open(addr_file, 'a') do |f|
      f.puts "#{tstamp},#{addr}"
    end
    addr
  end
end

