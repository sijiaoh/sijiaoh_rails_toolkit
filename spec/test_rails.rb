require "fileutils"

# Create rails project under tmp directory.
module TestRails
  DIR = "/tmp/#{SijiaohRailsToolkit.name.downcase}/test_rails".freeze

  def create!
    assert_project_not_generated

    create_directory
    copy_dotbundle_to_directory

    rails_new
  end

  def destroy
    FileUtils.rm_rf DIR
  end

  def system!(command)
    assert_project_generated
    system(
      # bundlerの環境引数が引き継がれないようにする。
      { "PATH" => "#{DIR}/bin:#{ENV.fetch('PATH', nil)}" },
      command,
      chdir: DIR,
      exception: true,
      unsetenv_others: true
    )
  end

  def glob(pattern)
    assert_project_generated
    Dir.glob(File.join(DIR, pattern))
  end

  def file_exists?(path)
    assert_project_generated
    File.exist?(File.join(DIR, path))
  end

  def read_file(path)
    assert_project_generated
    File.read(File.join(DIR, path))
  end

  private

  def assert_project_generated
    raise "Project not generated" unless File.exist?(File.join(DIR, "Gemfile"))
  end

  def assert_project_not_generated
    raise "Project generated" if File.exist?(File.join(DIR, "Gemfile"))
  end

  def create_directory
    FileUtils.mkdir_p DIR
  end

  def copy_dotbundle_to_directory
    FileUtils.cp_r ".bundle", DIR
  end

  def rails_new
    # system!とは違いこちらはbundlerの環境変数を引き継いで、プロジェクト指定のrailsのバージョンを使用する。
    system "yes | bundle exec rails new --skip-git #{DIR}", exception: true
  end
end
