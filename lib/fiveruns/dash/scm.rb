require 'date'
module Fiveruns::Dash
  class SCM
    include Typable
    
    def self.matching(startpath)
      scm_hash = {}
      types.each do |name, klass|
        if path = locate_upwards(startpath, ".#{name}")
          Fiveruns::Dash.logger.info "SCM: Found #{name} in #{path}"
          scm_hash[path] = klass
        end
      end
      winning_path = best_match(scm_hash.keys)
      return nil if winning_path.nil?
      Fiveruns::Dash.logger.info "SCM: Using #{scm_hash[winning_path].name} in #{winning_path}" 
      begin
        scm_hash[winning_path].new(winning_path)
      rescue Exception => e
        Fiveruns::Dash.logger.warn "WARNING: #{e.message}"
        nil
      end
    end
    
    def self.best_match( scm_paths )
      scm_paths.max{|a,b| a.split("/").length <=> b.split("/").length}
    end
    
    def initialize(path)
      @path = path
      require_binding
    end
    
    def time
      raise NotImplementedError, 'Abstract'
    end
    
    def revision
      raise NotImplementedError, 'Abstract'
    end
    
    #######
    private
    #######
    
    def self.locate_upwards(startpath, target)
      return nil unless startpath
      startpath = File.expand_path(startpath)
      return startpath if File.exist?(File.join( startpath, target ))
      return locate_upwards( File.dirname(startpath), target) unless File.dirname(startpath) == startpath
      nil
    end

    def require_binding
    end
    
  end
  
  class GitSCM < SCM

    def revision
      head.id
    end

    def time
      head.committed_date
    end

    def url
      repo.config.fetch('remote.origin.url', '')
    end

    #######
    private
    #######

    def head
      @head ||= begin
        sha = repo.head.commit
        repo.commits(sha)[0]
      end
    end

    def repo
      @repo ||= Grit::Repo.new(@path)
    end

    def require_binding
      require 'grit'
      Fiveruns::Dash.logger.info "GIT: #{revision} / #{time} / #{url}"
    rescue LoadError
      raise LoadError, "Dash deployment tracking for Git apps requires the 'grit' gem"
    end
    
  end

  class SvnSCM < SCM
    
    def revision
        @yaml['Last Changed Rev'] || @yaml['Revision']
    end
    
    def time
      datestring = @yaml['Last Changed Date']
      datestring.nil? ? nil : DateTime.parse(datestring.split("(").first.strip)
    end
    
    def url
      @url ||= @yaml['URL']
    end
    
    #######
    private
    #######
    
    def require_binding
      @yaml = YAML.load(svn_info)
      @yaml = {} unless Hash === @yaml
    end

    def svn_info
      `svn info #{@path}`
    end
    
  end
  
end