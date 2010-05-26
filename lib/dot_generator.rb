module DotGenerator
  
  def to_dot thing
    dot = dot_header "Investigation"
    
    if thing.instance_of?(Investigation)
      dot += to_dot_inv thing
    end
    
    if thing.instance_of?(Study)
      dot += to_dot_study thing
    end
    
    if thing.instance_of?(Assay)
      dot += to_dot_assay thing
    end
    
    dot << "}"
    return dot
  end
  
  def to_dot_inv investigation    
    dot = ""
    dot << "Inv_#{investigation.id} [label=\"#{multiline(investigation.title)}\",tooltip=\"#{investigation.title}\",shape=box,style=filled,fillcolor=skyblue3,URL=\"#{polymorphic_path(investigation)}\",target=\"_top\"];\n"
    investigation.studies.each do |s|
      dot << to_dot_study(s,show_assets=false)
      dot << "Inv_#{investigation.id} -- Study_#{s.id}\n"
    end
    return dot
  end
  
  def to_dot_study study, show_assets=true
    dot = ""
    dot << "Study_#{study.id} [label=\"#{multiline(study.title)}\",tooltip=\"#{study.title}\",shape=box,style=filled,fillcolor=chocolate,URL=\"#{polymorphic_path(study)}\",target=\"_top\"];\n"
    study.assays.each do |assay|
      dot << to_dot_assay(assay, show_assets)
      dot << "Study_#{study.id} -- Assay_#{assay.id}\n"
    end
    return dot  
  end
  
  def to_dot_assay assay, show_assets=true
    dot = ""
    dot << "Assay_#{assay.id} [label=\"#{multiline(assay.title)}\",tooltip=\"#{assay.title}\",shape=folder,style=filled,fillcolor=burlywood,URL=\"#{polymorphic_path(assay)}\",target=\"_top\"];\n"    
    if (show_assets) 
      assay.assets.each do |asset|
        asset_type=asset.resource.class.name
        if Authorization.is_authorized?("view",nil,asset,current_user)
          dot << "Asset_#{asset.resource.id} [label=\"#{multiline(asset.resource.title)}\",tooltip=\"#{asset.resource.title}\",shape=box,fontsize=7,style=filled,fillcolor=gold,URL=\"#{polymorphic_path(asset.resource)}\",target=\"_top\"];\n"
          dot << "Assay_#{assay.id} -- Asset_#{asset.resource.id}\n"
        else
          dot << "Asset_#{asset.resource.id} [label=\"Hidden Item\",tooltip=\"Hidden Item\",shape=box,fontsize=6,style=filled,fillcolor=lightgray];\n"
          dot << "Assay_#{assay.id} -- Asset_#{asset.resource.id}\n"
        end
      end
    end  
    return dot
  end
  
  
  def to_svg thing
    tmpfile = Tempfile.new("#{thing.class.name}_dot")
    file = File.new(tmpfile.path,'w')
    file.puts to_dot(thing)
    file.close    
    post_process_svg(`dot -Tsvg #{tmpfile.path}`)
  end
  
  def dot_header title
    dot = "graph #{title} {"
    dot << "rankdir = LR;"    
    #dot << "splines = line;"
    dot << "node [fontsize=9,fontname=\"Helvetica\"];"    
    dot << "bgcolor=white;" 
    dot << "edge [arrowsize=0.6];\n" 
    return dot
  end
  
  def to_png thing
    tmpfile = Tempfile.new("#{thing.class.name}_dot")
    file = File.new(tmpfile.path,'w')
    file.puts to_dot(thing)
    file.close    
    puts "saved to tmp file: "+tmpfile.path
    `dot -Tpng #{tmpfile.path}`
  end
  
  #fixes a problem with missing units, which causes Firefox to incorrectly display.
  #this will fail if the font-size set is not a whole integer  
  def post_process_svg svg
    return svg.gsub(".00;",".00px;")
  end
  
  def multiline str,line_len=3    
    new_str=str[0..80]
    
    str+=" ..." if str.length>500
    word_arr=new_str.split
    x=line_len
    while x<new_str.split.length do
      word_arr.insert(x,"\\n")
      x+=line_len+1
    end
    
    end_str = (new_str.length!=str.length) ? " ..." : ""
    word_arr.join(" ") + end_str
  end
  
end
