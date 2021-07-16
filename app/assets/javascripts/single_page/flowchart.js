let existingAssays = [];
let AssayDetails = [];
let streams = [];

function setInputNum() {
  let num = $j(this).val();
  if (num >= 0 && num < 4) $j(".wf_btn").data("nb-inputs", num);
}

function setOutputNum() {
  let num = $j(this).val();
  if (num >= 0 && num < 4) $j(".wf_btn").data("nb-outputs", num);
}

function saveAssay() {
  if (!$j("#modalMethodfile")[0].files[0]) {
    alert("Please select method file");
    return;
  } else if (!$j("#assayTitle").val()) {
    alert("Please enter assay title.");
    return;
  } else if (!$j("#modalMethodTitle").val()) {
    alert("Please enter method title.");
    return;
  }
  var Id = $j("#chart_canvas").flowchart("getSelectedOperatorId");
  AssayDetails.push({
    opId: Id,
    title: $j.trim($j("#assayTitle").val()),
    description: $j.trim($j("#assayDes").val()),
    method: {
      type: $j("#method_type").val() || 0,
      file: $j("#modalMethodfile")[0].files[0],
      title: $j("#modalMethodTitle").val(),
      description: $j("#modalMethodDes").val()
    },
    sampleTypeAttrId: $j("#assayType").find(":selected").val()
  });
  //Add the method detail:
  $j("#chart_canvas").flowchart("setOperatorTitle", Id, $j("#modalMethodTitle").val());
  $j("#close").click();
}

function cancelAssay() {
  $j("#assayInfo").hide();
  removeBlock();
}

const removeBlock = () => {
  $j("#chart_canvas").flowchart("deleteSelected");
};

const addAssayTypeOptions = () => {
  $j("#assayType").empty();
  let organized = AssayTypes.reduce((obj, item) => {
    obj[item.group] = obj[item.group] || [];
    obj[item.group].push(item);
    return obj;
  }, {});

  let counter = 0;
  $j.each(Object.keys(organized), (i, item) => {
    const elem = $j(`<optgroup label=${item}></optgroup>`);
    $j.each(organized[item], (j, subItem) => {
      elem.append($j(`<option>${subItem.title}</option>`).attr("value", counter).text(item.title));
      counter++;
    });
    $j("#assayType").append(elem);
  });

  // $j.each(AssayTypes, (key, value) => {
  //   $j("#assayType").append($j("<option></option>").attr("value", key).text(value.title));
  // });
  if (AssayTypes[0])
    $j.each(AssayTypes[0].attributes, (k, attr) => {
      const newRow = attr.required
        ? "<td><input disabled checked type='checkbox'/></td>"
        : "<td><input type='checkbox'/></td>";
      let title = attr.required ? "<strong>" + attr.title + "*" + "</strong>" : attr.title;
      $j("#assayAttribs tbody").append(
        `<tr>${newRow}<td>${title}</td><td>${attr.shortName || ""}</td><td>${attr.des || ""}</td></tr>`
      );
    });
};

const handleAssayTypeChange = () => {
  const i = $j("#assayType").find(":selected").val();

  // $j("#attribs").empty()
  $j("#assayAttribs tbody").empty();
  $j("#method_type").val(i);
  $j("#assayTitle").val(AssayTypes[i].title);
  $j.each(AssayTypes[i].attributes, (k, attr) => {
    const newRow = attr.required
      ? "<td><input disabled checked type='checkbox'/></td>"
      : "<td><input type='checkbox'/></td>";
    let title = attr.required ? "<strong>" + attr.title + "*" + "</strong>" : attr.title;
    $j("#assayAttribs tbody").append(
      `<tr>${newRow}<td>${title}</td><td>${attr.shortName}</td><td>${attr.des}</td></tr>`
    );
  });
};

const getAssayDetail = (opId) => AssayDetails.find((a) => a.opId == opId);

function createAssay(pid, std_id, uid, title, desc, sopId, position) {
  return new Promise((resolve) => {
    const data = createAssayStruct(title, desc, position, pid, std_id, sopId, uid);

    let params = {};
    params.onSuccess = (s) => {
      console.log("assay was created successfully! : " + s.data.id);
      resolve(s);
    };
    params.onError = (e) => alert("An error occurred when creating assay");
    params.data = JSON.stringify(data);
    params._return = true;
    ajaxCall("/assays", "POST", params);
  });
}

const createSOP = (title, desc, pid, uid, file) => {
  return new Promise((resolve) => {
    const data = createSOPStruct(title, desc, file.name, file.type, pid, uid);

    let params = {};
    params.onSuccess = (s) => {
      console.log(`SOP was created successfully!: ${s.data.id}`);
      resolve(s);
    };
    params.onError = (e) => alert("An error occurred when creating SOP");
    params.data = JSON.stringify(data);
    params._return = true;
    ajaxCall("/sops", "POST", params);
  });
};

const seekSampleAttribute = (linked_sample_type_id) => ({
  attribute_type_id: 17,
  required: true,
  title: "sample_connect",
  linked_sample_type_id
});

const arrEqualItems = (arr1, arr2) => {
  arr1 = $j.map(arr1, (item) => item.id);
  arr2 = $j.map(arr2, (item) => item.id);
  for (let i = 0; i < arr1.length; i++) {
    if ($j.inArray(arr1[i], arr2) == -1) return false;
  }
  return true;
};

const test = () => console.log(JSON.stringify(fl.getData()));

const fl = {
  init: function () {
    var $flowchart = $j("#chart_canvas");
    var $container = $flowchart.parent();
    var $operatorProperties = $j("#operator_properties");
    var $linkProperties = $j("#link_properties");
    var $operatorTitle = $j("#operator_title");
    var $linkColor = $j("#link_color");
    $flowchart.flowchart({
      onOperatorSelect: function (operatorId) {
        $operatorProperties.show();
        $operatorTitle.val($flowchart.flowchart("getOperatorTitle", operatorId));
        $operatorProperties.css("position", "absolute");
        $operatorProperties.css("left", this.data.operators[operatorId].left - 28);
        $operatorProperties.css("top", this.data.operators[operatorId].top - 42);
        return true;
      },
      onOperatorUnselect: () => {},
      onLinkSelect: (linkId) => {
        $linkProperties.show();
        $linkColor.val($flowchart.flowchart("getLinkMainColor", linkId));
        return true;
      },
      onLinkUnselect: () => {
        $linkProperties.hide();
        return true;
      },
      onLinkCreate: (linkId, linkData) => {
        if (linkData.fromOperator == "0") {
          console.log("connected to source!");
        }
        return true;
      }
    });

    $operatorTitle.keyup(() => {
      var selectedOperatorId = $flowchart.flowchart("getSelectedOperatorId");
      if (selectedOperatorId != null) {
        $flowchart.flowchart("setOperatorTitle", selectedOperatorId, $operatorTitle.val());
      }
    });
    $j(".delete_selected_button").click(() => {
      $flowchart.flowchart("deleteSelected");
      $j("#operator_properties").hide();
    });
    var $draggableOperators = $j(".draggable_operator");

    const getOperatorData = ($element) => {
      const nbInputs = parseInt($element.data("nb-inputs"));
      const nbOutputs = parseInt($element.data("nb-outputs"));
      var data = {
        properties: {
          title: $element.text(),
          inputs: {},
          outputs: {},
          shape: $element.data("shape"),
          assay_id: $element.data("assay_id"),
          sample_type_id: $element.data("sample_type_id")
        }
      };
      for (let i = 0; i < nbInputs; i++) {
        data.properties.inputs["input_" + i] = {
          label: "Input " + (i + 1)
        };
      }
      for (let i = 0; i < nbOutputs; i++) {
        data.properties.outputs["output_" + i] = {
          label: "Output " + (i + 1),
          multiple: true
        };
      }
      return data;
    };
    $draggableOperators.draggable({
      cursor: "move",
      opacity: 0.7,
      appendTo: "body",
      zIndex: 1000,
      helper: function (e) {
        let $this = $j(this);
        let data = getOperatorData($this);
        return $flowchart.flowchart("getOperatorElement", data);
      },
      stop: function (e, ui) {
        let $this = $j(this);
        let elOffset = ui.offset;
        let containerOffset = $container.offset();
        if (
          elOffset.left > containerOffset.left &&
          elOffset.top > containerOffset.top &&
          elOffset.left < containerOffset.left + $container.width() &&
          elOffset.top < containerOffset.top + $container.height()
        ) {
          let flowchartOffset = $flowchart.offset();
          let relativeLeft = elOffset.left - flowchartOffset.left;
          let relativeTop = elOffset.top - flowchartOffset.top;
          let positionRatio = $flowchart.flowchart("getPositionRatio");
          relativeLeft /= positionRatio;
          relativeTop /= positionRatio;
          let data = getOperatorData($this);
          data.left = relativeLeft;
          data.top = relativeTop;
          let opId = $flowchart.flowchart("addOperator", data);
          $j("#assayInfo").modal("show");
          $flowchart.flowchart("selectOperator", opId);
          $j("#operator_properties").hide();
          $j("#assayTitle").val(AssayTypes[$j("#assayType").find(":selected").val()].title);
        }
      }
    });
    console.log("Flowchart was initialized.");
  },
  getData: function () {
    return $j("#chart_canvas").flowchart("getData");
  },
  getOperators: function () {
    const data = fl.getData().operators;
    return $j.map(data, function (value, index) {
      return [value];
    });
  },
  getLinks: function () {
    const data = fl.getData().links;
    return $j.map(data, function (value, index) {
      return [value];
    });
  },
  getByTitle: function (title) {
    return fl.getOperators().find((op) => op.properties.title === title);
  },
  getById: function (id) {
    return fl.getOperators()[id];
  },
  getIdByTitle: function (title) {
    return fl.getOperators().findIndex((op) => op.properties.title === title);
  },
  updateOperator: function (field, title, id) {
    let data = fl.getData();
    $j.each(data.operators, function (i, op) {
      if (op.properties.title == title) {
        op.properties[field] = id;
      }
    });
    fl.setData(data);
  },
  setData: function (data) {
    $j("#chart_canvas").flowchart("setData", data);
  },
  getParentSampleTypeId: function (title) {
    const opId = fl.getIdByTitle(title);
    const parentOpId = fl.getLinks().find((l) => l.toOperator == opId).fromOperator;
    const parentOp = fl.getById(parentOpId);
    if (!parentOp) throw Error("Error finding parent block");
    return parentOp.properties.sample_type_id;
  },
  update: function () {
    console.log(fl.provideStreamData());
    const data = {
      flowchart: {
        study_id: selectedItem.id,
        items: JSON.stringify(fl.getData()),
        streams: fl.provideStreamData()
      }
    };

    let params = {};
    params.onSuccess = (s) => location.reload();
    params.onError = (e) => console.error("error updating Flowchart!");
    params.data = JSON.stringify(data);
    params.dataType = "json";
    console.log(params.data);
    ajaxCall(`/single_pages/${pid}/update_flowchart`, "POST", params);
  },
  validate: function () {
    const data = fl.getData();
    const operatorsLength = Object.keys(data.operators).length;
    const linksLength = Object.keys(data.links).length;
    if (operatorsLength == 0) return true;
    if (operatorsLength - linksLength != 1) {
      alert("The items must be connected.");
      return false;
    }

    let names = [];
    let nameIsValid = true;
    $j.each(data.operators, (op_key, op_val) => {
      names.push(op_val.properties.title);
    });
    $j.each(names, (id, val) => {
      $j.each(names, (i, v) => {
        if (i != id && val == v) {
          alert("Duplicate names detected!");
          nameIsValid = false;
          return false;
        }
      });
      if (!nameIsValid) return false;
    });
    return nameIsValid ? true : false;
  },
  load: function () {
    $j("#source_characteristics_panel").addClass("disabled");
    $j("#source_table_panel").removeClass("disabled");

    const $flowchart = $j("#chart_canvas");
    const { id, type } = selectedItem;
    if (type != "study") {
      console.error("Selected item is not a study");
      return;
    }
    let params = {};
    params.onSuccess = (s) => {
      if (!s.data) {
        fl.hide();
        return;
      }
      $j("#flowchart-header").show();
      $flowchart.flowchart("setData", s.data || "");
      existingAssays = $j.map(s.data.operators, (op, i) => {
        if (op.properties.assay_id != "")
          return {
            id: op.properties.assay_id,
            sopTitle: op.properties.title
          };
      });
      console.log("Existing Assays:", existingAssays);
    };
    params.onError = (e) => fl.hide();
    params.dataType = "json";
    ajaxCall(`/single_pages/${pid}/flowchart/${id}`, "GET", params);
  },
  promptForStreams: function () {
    if (selectedItem.type != "study") return;
    if (fl.validate() == false) return;

    fl.initStreams();
    $j("#streams").modal("show");
  },
  save: function () {
    // $j(event.target).attr("disabled", true);
    console.log("save");
    let newAssays = fl.extractAssays(fl.getData());
    console.log(newAssays);
    if (arrEqualItems(newAssays, existingAssays)) {
      console.log("No assay to save...");
      fl.update();
      return;
    }

    for (const [i, assay] of newAssays.entries()) {
      const tempArr = $j.map(existingAssays, (a) => a.id);
      if ($j.inArray(assay.id, tempArr) == -1) {
        const { title, description, method, sampleTypeAttrId } = getAssayDetail(assay.opId);
        createSOP(method.title, method.description, pid, uid, method.file).then((res1) => {
          createAssay(pid, selectedItem.id, uid, title, description, res1.data.id, i).then((res2) => {
            fl.updateOperator("assay_id", method.title, res2.data.id);
            // Add seek_sample attribute type
            const attributes = AssayTypes[sampleTypeAttrId].attributes;
            // Passing the previous box sample_type_id
            const linked_sample_type_id = fl.getParentSampleTypeId(method.title);
            const data = sampleTypeData(
              [...attributes, seekSampleAttribute(linked_sample_type_id)],
              `sample_type_${res2.data.id}`,
              res2.data.id
            );
            createSampleType(data, () => {}).then((res3) => {
              fl.updateOperator("sample_type_id", method.title, res3.data.id);
              if (i == newAssays.length - 1) {
                fl.update();
              }
            });
          });
        });
      }
    }

    // asyncForEach(newAssays, async (i, assay) => {
    //   const tempArr = $j.map(existingAssays, (a) => a.id);
    //   if ($j.inArray(assay.id, tempArr) == -1) {
    //     const { title, description, method, sampleTypeAttrId } = getAssayDetail(assay.opId);
    //     const res1 = await createSOP(method.title, method.description, pid, uid, method.file);
    //     const res2 = await createAssay(pid, selectedItem.id, uid, title, description, res1.data.id, i);
    //     fl.updateOperator("assay_id", method.title, res2.data.id);
    //     // Add seek_sample attribute type
    //     const attributes = AssayTypes[sampleTypeAttrId].attributes;
    //     // Passing the previous box sample_type_id
    //     const linked_sample_type_id = fl.getParentSampleTypeId(method.title);
    //     const data = sampleTypeData(
    //       [...attributes, seekSampleAttribute(linked_sample_type_id)],
    //       `sample_type_${res2.data.id}`,
    //       res2.data.id
    //     );
    //     const res3 = await createSampleType(data, () => {});
    //     fl.updateOperator("sample_type_id", method.title, res3.data.id);
    //     if (i == newAssays.length - 1) {
    //       fl.update();
    //     }
    //   }
    // });
  },
  refresh: function () {
    setTimeout(() => {
      $j("#chart_canvas").flowchart("redrawLinksLayer");
    }, 250);
  },
  hide: function () {
    $j("#source_characteristics_panel").removeClass("disabled");
    $j("#source_table_panel").addClass("disabled");
    $j("#flowchart-header").hide();
    window.location.href = "#study-details";
  },
  extractStreams: function () {
    let _streams = [];
    const extract = (l, s = [0]) => {
      let current = s[s.length - 1],
        c;
      for (const link of l) {
        let t = s.slice();
        if (link.fromOperator == current) {
          t.push(link.toOperator);
          extract(l, t);
          c = 1;
        }
      }
      if (!c) _streams.push(s);
    };
    extract(fl.getLinks());
    return _streams;
  },
  getOrderedOps: function () {
    return streams.reduce((t, i) => [...t, ...$j.grep(i, (x) => !t.includes(x))]);
  },
  extractAssays: function () {
    const operators = fl.getOperators();
    console.log("operators", operators);
    // Remove source operator
    const ordered = fl.getOrderedOps();
    console.log("ordered", ordered);
    let operatorsIds = ordered.slice(1);
    console.log("operatorsIds", operatorsIds);
    return $j.map(operatorsIds, (id, i) => ({
      id: operators[id].properties.assay_id,
      opId: id // for using to identify Assay name associated with the method
    }));
  },
  initStreams: function () {
    streams = fl.extractStreams();
    console.log("streams", streams);
    const operators = fl.getOperators();
    console.log("operators", operators);
    const container = $j("#stream-items");
    container.empty();
    for (let s = 0; s < streams.length; s++) {
      let text = s + 1 + ") ";
      for (let i = 0; i < streams[s].length; i++) {
        text += operators[streams[s][i]].properties.title + " > ";
      }
      const item = $j(`<div class="stream" class="col-md-12" style="margin:5px"></div>`);
      item.append(`<small style="color:#555;overflow-x:hidden">${text.slice(0, -2)}</small>`);
      item.append("</br>");
      item.append(`<input type='text' class='form-control' placeholder='Stream name'/>`);

      container.append(item);
    }
    console.log(container);
  },
  provideStreamData: function () {
    const operators = fl.getOperators();
    return $j.map($j("#stream-items .stream"), (e, i) => {
      const ids = streams[i];
      const title = $j($j(e).children(":input")[0]).val();
      return {
        title,
        items: $j.map(ids, (id) => ({
          sample_type_id: operators[id].properties.sample_type_id
        }))
      };
    });
  }
};

// const asyncForEach = async (array, callback) => {
//   for (let index = 0; index < array.length; index++) {
//     await callback(index, array[index], array);
//   }
// };
