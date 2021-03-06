module Medie
  module OpenSearch
    class Descriptor
      
      def use(content_type)
        uri = urls.find do |url|
          url["type"]==content_type
        end
        return nil if uri.nil?
    
        base_uri, params_pattern = extract_uri(uri)
        Restfulie.at(base_uri).accepts(content_type).open_search.with_pattern(params_pattern)
      end
  
      private
      def extract_uri(uri)
        uri = uri["template"]
        interrogation = uri.index("?")
        params = uri[interrogation+1..uri.size]
        base_uri = uri[0..interrogation-1]
        [base_uri, params]
      end

    end
  end
end