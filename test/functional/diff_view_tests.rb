require 'test_helper'

# > cd cyberdojo/test
# > ruby functional/diff_view_tests.rb

def diff_view(avatar, tag)

    #tag = 2    
    cmd  = "cd #{avatar.folder};"
    cmd += "git diff #{tag-1} #{tag} sandbox;"   
    diff = IO::popen(cmd).read

    diff = GitDiffParser.new(diff).parse

    # Now grab the current version of the file
    cmd  = "cd #{avatar.folder};"
    cmd += "git show #{tag}:manifest.rb;"
    manifest = eval IO::popen(cmd).read
    
    source_lines = manifest[:visible_files]['untitled.rb'][:content]
    
    builder = GitDiffBuilder.new()
    source_diff = builder.build(diff, source_lines.split("\n"))

    { 'untitled.rb' => source_diff }
end

#-----------------------------------------------
#-----------------------------------------------
#-----------------------------------------------

class DiffViewTests < ActionController::TestCase

  ROOT_TEST_FOLDER = 'test_dojos'
  DOJO_NAME = 'Jon Jagger'
  # the test_dojos sub-folder for 'Jon Jagger' is
  # 38/1fa3eaa1a1352eb4bd6b537abbfc4fd57f07ab

  def root_test_folder_reset
    system("rm -rf #{ROOT_TEST_FOLDER}")
    Dir.mkdir ROOT_TEST_FOLDER
  end

  def make_params
    { :dojo_name => DOJO_NAME, 
      :dojo_root => Dir.getwd + '/' + ROOT_TEST_FOLDER,
      :filesets_root => Dir.getwd + '/../filesets'
    }
  end

  #-----------------------------------------------
  
  def test_building_diff_view_from_git_repo
    root_test_folder_reset
    params = make_params
    assert Dojo::create(params)
    dojo = Dojo.new(params)
    language = 'Ruby'
    avatar = dojo.create_avatar({ 'language' => language })    
    # that will have created tag 0 in the repo

test_untitled_rb = <<HERE
require 'untitled'
require 'test/unit'

class TestUntitled < Test::Unit::TestCase

  def test_simple
    assert_equal 9 * 6, answer  
  end

end
HERE

untitled_rb = <<HERE
def answer
  42
end
HERE

    manifest =
    {
      :visible_files =>
      {
        'cyberdojo.sh' =>
        {
          :content => 'ruby test_untitled.rb'
        },
        'untitled.rb'=>
        {
          :content => untitled_rb
        },
        'test_untitled.rb' =>
        {
          :content => test_untitled_rb
        }
      }
    }

    # create tag 1 in the repo 
    increments = avatar.run_tests(manifest)
    assert_equal :failed, increments.last[:outcome]

    # create tag 2 in the repo 
    manifest[:visible_files]['untitled.rb'][:content] = untitled_rb.sub('42', '54')
    increments = avatar.run_tests(manifest)
    assert_equal :passed, increments.last[:outcome]

    
    tag = 2    
    view = diff_view(avatar, tag)
    
    expected =
    {
      'untitled.rb' =>
      [
        { :line => "def answer", :type => :same, :number => 1 },
        { :line => "  42", :type => :deleted },
        { :line => "  54", :type => :added, :number => 2 },
        { :line => "end", :type => :same, :number => 3 },
      ]
    }
    assert_equal expected, view
    
  end
  
end
