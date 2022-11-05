require "fileutils"

# Create rails project under tmp directory.
module TestRails # rubocop:disable Metrics/ModuleLength
  BASE_DIR = File.join "/", "tmp", SijiaohRailsToolkit.name.downcase
  VENDOR_DIR = File.join BASE_DIR, "vendor"
  BACKUP_DIR = File.join BASE_DIR, "test_rails_backup"
  RAILS_DIR = File.join BASE_DIR, "test_rails"

  def create!
    assert_project_not_generated

    create_directory
    copy_dotbundle_to_directory

    rails_new
    bundle_install
    install_this_gem
    create_backup
  end

  def destroy
    FileUtils.rm_rf RAILS_DIR
    FileUtils.rm_rf BACKUP_DIR
    # Not remove vendor directory to use it as cache for next test.
  end

  def reset
    FileUtils.rm_rf RAILS_DIR
    FileUtils.cp_r BACKUP_DIR, RAILS_DIR
  end

  def system!(command)
    assert_project_generated
    system(
      # bundlerの環境引数が引き継がれないようにする。
      { "PATH" => "#{RAILS_DIR}/bin:#{ENV.fetch('PATH', nil)}" },
      command,
      chdir: RAILS_DIR,
      exception: true,
      unsetenv_others: true
    )
  end

  def to_rails_path(path)
    File.join RAILS_DIR, path
  end

  def glob(pattern)
    assert_project_generated
    Dir.glob(to_rails_path(pattern))
  end

  def file_exists?(path)
    assert_project_generated
    File.exist?(to_rails_path(path))
  end

  def mkdir(path)
    assert_project_generated
    FileUtils.mkdir_p(to_rails_path(path))
  end

  def rm(path)
    assert_project_generated
    FileUtils.rm_rf(to_rails_path(path))
  end

  def read_file(path)
    assert_project_generated
    File.read(to_rails_path(path))
  end

  def write_file(path, content)
    assert_project_generated
    File.write(to_rails_path(path), content)
  end

  def ls(path = "", full_path: false)
    assert_project_generated
    if full_path
      glob(File.join(path, "*"))
    else
      glob(File.join(path, "*")).map { |f| File.basename(f) }
    end
  end

  private

  def assert_project_generated
    raise "Project not generated" unless File.exist?(to_rails_path("Gemfile"))
  end

  def assert_project_not_generated
    raise "Project generated" if File.exist?(to_rails_path("Gemfile"))
  end

  def create_directory
    FileUtils.mkdir_p RAILS_DIR
  end

  def copy_dotbundle_to_directory
    FileUtils.cp_r ".bundle", RAILS_DIR
  end

  def rails_new
    # system!とは違いこちらはbundlerの環境変数を引き継いで、プロジェクト指定のrailsのバージョンを使用する。
    system "yes | bundle exec rails new --skip-bundle --skip-git #{RAILS_DIR}", exception: true
  end

  def bundle_install
    FileUtils.mkdir_p VENDOR_DIR
    rm "vendor"
    system! "ln -sf #{VENDOR_DIR} #{to_rails_path('vendor')}"
  end

  def install_this_gem
    gemfile = read_file "Gemfile"
    write_file "Gemfile", gemfile + "\ngem 'sijiaoh_rails_toolkit', path: '#{project_root_dir}'\n"

    system! "bundle install"
  end

  def project_root_dir
    current_dir = File.expand_path(".")
    while current_dir != "/"
      return current_dir if File.exist?(File.join(current_dir, "Gemfile"))

      current_dir = File.dirname(current_dir)
    end
    raise "Gemfile not found"
  end

  def create_backup
    FileUtils.rm_rf BACKUP_DIR
    FileUtils.cp_r RAILS_DIR, BACKUP_DIR
  end
end
