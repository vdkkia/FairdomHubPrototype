require 'rubygems'
require 'rake'


namespace :seek do
  desc "Fetch ontology terms from EBI API"
  task :populate_repository_standars => :environment do
    begin
      RepositoryStandard.delete_all
      SampleControlledVocab.delete_all
      SampleControlledVocabTerm.delete_all
    
      disable_authorization_checks do
        client = Ebi::OlsClient.new
        Dir.foreach(File.join(Rails.root, 'config/default_data/source_types/')) do |filename|
          puts filename
          next if File.extname(filename) != '.json'
          data_hash = JSON.parse(File.read(File.join(Rails.root, 'config/default_data/source_types/', filename)))
          data_hash["data"].each do |item|
            metadata = item["metadata"]
            repo = RepositoryStandard.find_or_create_by({
            title: metadata["name"], 
            group: metadata["group"], 
            group_order: metadata["group_order"], 
            temporary_name: metadata["temporary_name"], 
            template_version: metadata["template_version"], 
            isa_config: metadata["isa_config"], 
            isa_measurement_type: metadata["isa_measurement_type"], 
            isa_technology_type: metadata["isa_technology_type"], 
            isa_protocol_type: metadata["isa_protocol_type"], 
            repo_schema_id: metadata["repo_schema_id"], 
            organism: metadata["organism"], 
            level: metadata["level"]})
  
            item["data"].each_with_index do |attribute, j|
              has_ontology = !attribute["ontology"].blank?
              obj = { title: attribute["name"], 
                    short_name: attribute["short_name"],
                    required: attribute["required"],
                    description: attribute["description"]}
  
              if has_ontology
                obj = obj.merge(
                  {  #description: attribute["ontology"]["description"],
                  source_ontology: attribute["ontology"]["name"],
                  ols_root_term_uri: attribute["ontology"]["rootTermURI"]}) 
              else
                if attribute["CVList"].blank?
                  # To be bypassed in cv attribute value checker
                  obj = obj.merge({ source_ontology: "free_text" }) 
                end
              end
  
              scv = SampleControlledVocab.new(obj)
  
              scv.repository_standard = repo
              
              if has_ontology
                if !attribute["ontology"]["rootTermURI"].blank?
                  begin
                    terms = client.all_descendants(attribute["ontology"]["name"], attribute["ontology"]["rootTermURI"])
                  rescue Exception => e
                    scv.save
                    next
                  end
                  terms.each_with_index do |term, i|
                    puts "#{j}) #{i+1} FROM #{terms.length}"
                    if (!term[:label].blank? && !term[:iri].blank?)
                      cvt = SampleControlledVocabTerm.new({ label: term[:label], iri: term[:iri], parent_iri: term[:parent_iri] })
                      scv.sample_controlled_vocab_terms << cvt
                    end
                  end
                end
              else #the CV terms
                if !attribute["CVList"].blank?
                  attribute["CVList"].each do |term|
                    cvt = SampleControlledVocabTerm.new({ label: term })
                    scv.sample_controlled_vocab_terms << cvt
                  end
                end
              end
  
              if !scv.save
                puts scv.errors.inspect
              end
            end
  
          end
        end
      end
    rescue Exception => e
      puts e
    end
  end
end