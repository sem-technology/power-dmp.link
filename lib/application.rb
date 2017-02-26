module Application
  def root
    Pathname.new(File.expand_path("./../../", __FILE__))
  end

  module_function :root
end
