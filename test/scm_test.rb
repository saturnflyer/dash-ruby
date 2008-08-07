require File.dirname(__FILE__) << "/test_helper"
require 'date'

#weird problems with flexmock resulted in this
module Fiveruns
  module Dash
    class SvnSCM
      private
      def svn_info
        <<-EOF
        Path: .
        URL: http://me.svnrepository.com/svn/dash/trunk
        Repository Root: http://me.svnrepository.com/svn/dash/trunk
        Repository UUID: f206d12c-05cc-4c44-99a1-426015a0eef1
        Revision: 123
        Node Kind: directory
        Schedule: normal
        Last Changed Author: acf
        Last Changed Rev: 123
        Last Changed Date: 2008-07-27 18:44:52 +0100 (Sun, 27 Jul 2008)
        EOF
      end
    end
  end
end

class ScmTest < Test::Unit::TestCase

  include Fiveruns::Dash  
  
  context "All SCMs" do
    should "find .git in plugin/core on locate_upwards" do
      scm = SCM.new( File.dirname(__FILE__) )
      assert_match %r(plugin/core$), scm.send(:locate_upwards, File.dirname(__FILE__), ".git" )
    end

    should "return nil from locate_upwards when no .git" do
      scm = SCM.new( File.dirname(__FILE__) )
      assert_nil scm.send(:locate_upwards, '/tmp', ".git" )
    end
  
    should "return nil from locate_upwards when root on posix" do
      scm = SCM.new( File.dirname(__FILE__) )
      assert_nil scm.send(:locate_upwards, "/", ".git" )
    end

    should "return nil from locate_upwards when root on windoze" do
      scm = SCM.new( File.dirname(__FILE__) )
      assert_nil scm.send(:locate_upwards, "C:\\", ".git" )
    end
  end

  
  context "Subversion SCM" do
    setup do
      @scm = SvnSCM.new( File.dirname(__FILE__) )
    end
    
    should "extract revision properly from svn info" do
      assert_equal 123, @scm.revision
    end

    should "extract time properly from svn info" do
      assert_equal DateTime.parse("2008-07-27 18:44:52 +0100"), @scm.time
    end

    should "extract URL properly from svn info" do
      assert_equal "http://me.svnrepository.com/svn/dash/trunk", @scm.url
    end 
  end
  
end