var Action = function() {};

Action.prototype = {
run: function(parameters) {
    parameters.completionFunction({"URL": document.URL, "title": document.title
    });
},
finalize: function(parameters) {
    var customJavaSvript = parameters["customJavaScript"];
    eval(customJavaSvript);
}
};

var ExtensionPreprocessingJS = new Action
