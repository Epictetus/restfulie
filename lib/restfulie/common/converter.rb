module Restfulie
  module Common
    
    # Restfulie supports by default a series of media formats, such as
    # xml, json, atom, opensearch and form-urlencoded.
    # Use register to register your own media format, but
    # do not forget to contribute with your converter if
    # it is a well known media type that Restfulie still
    # does not support.
    module Converter
      Dir["#{File.dirname(__FILE__)}/converter/*.rb"].each {|f| autoload File.basename(f)[0..-4].camelize.to_sym, f }

      # Returns the default root element name for an item or collection
      def self.root_element_for(obj)
        if obj.kind_of?(Hash) && obj.size==1
          obj.keys.first.to_s
        elsif obj.kind_of?(Array) && !obj.empty?
          root_element_for(obj.first).to_s.underscore.pluralize
        else
          obj.class.to_s.underscore
        end
      end
      
      def self.register(media_type,representation)
        representations[media_type] = representation
      end

      def self.content_type_for(media_type)
        return nil if media_type.nil?
        content_type = media_type.split(';')[0] # [/(.*?);/, 1]
        representations[content_type]
      end
      
      # extracts the first converter that works for any of the acceptable media types
    	def self.find_for(accepts = [])
  			accepts.find do |accept|
  			  content_type_for(accepts[0])
  		  end
  	  end
  	  
      private
      
      def self.representations
        @representations ||= {}
      end
      
      register 'application/atom+xml' , ::Restfulie::Common::Converter::Atom
      register 'application/xml' , ::Restfulie::Common::Converter::Xml
      register 'text/xml' , ::Restfulie::Common::Converter::Xml
      register 'application/json' , ::Restfulie::Common::Converter::Json
      register 'application/opensearchdescription+xml' , ::Restfulie::Common::Converter::OpenSearch
      register 'application/x-www-form-urlencoded', Restfulie::Common::Converter::FormUrlEncoded
      
    end
  end
end

