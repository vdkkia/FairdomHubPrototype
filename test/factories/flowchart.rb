example_flowchart = '{"operators":{"0":{"left":40,"top":100,"properties":{"inputs":{},"outputs":{"output_0":{"label":"Output 1","multiple":true}},"shape":"parallelogram","assay_id":"","sample_type_id":"4","title":"Source Sample"}},"1":{"properties":{"title":"nucleic acid extraction1","inputs":{"input_0":{"label":"Input 1"}},"outputs":{"output_0":{"label":"Output 1","multiple":true}},"shape":"rectangle","assay_id":"3","sample_type_id":"5"},"left":300,"top":60},"2":{"properties":{"title":"nucleic acid extraction2","inputs":{"input_0":{"label":"Input 1"}},"outputs":{"output_0":{"label":"Output 1","multiple":true}},"shape":"rectangle","assay_id":"4","sample_type_id":"6"},"left":320,"top":220}},"links":{"0":{"fromOperator":"0","fromConnector":"output_0","fromSubConnector":0,"toOperator":1,"toConnector":"input_0","toSubConnector":0},"1":{"fromOperator":"0","fromConnector":"output_0","fromSubConnector":1,"toOperator":2,"toConnector":"input_0","toSubConnector":0}},"operatorTypes":{}}'
min_flowchart = '{links: {},operatorTypes: {},operators: {0: {left: 40,top: 100,properties: {inputs: {},outputs: { output_0: { label: "Output 1", multiple: true } },shape: "parallelogram",assay_id: "",sample_type_id: %,title: "Source Sample",},},},}'
Factory.define(:flowchart, class: Flowchart) do |f|
    f.study_id { Factory.create(:study).id }
    f.source_sample_type_id '1'
    f.after_build do |flowchart|
        id = Factory.create(:assay, study: flowchart.study, assay_assets: [Factory.create(:assay_asset, asset:Factory.create(:sop))]).id
        flowchart.items = example_flowchart
    end
end

Factory.define(:min_flowchart, class: Flowchart) do |f|
    f.after_build do |fl|
        fl.items = min_flowchart.sub! '%', fl.source_sample_type_id.to_s
    end
end