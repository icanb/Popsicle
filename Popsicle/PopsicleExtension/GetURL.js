var MyExtensionJavaScriptClass = function() {};

MyExtensionJavaScriptClass.prototype = {
run: function(arguments) {
    // Pass the baseURI of the webpage to the extension.
    arguments.completionFunction({"baseURI": document.baseURI});
},
    
    // Note that the finalize function is only available in iOS.
finalize: function(arguments) {
    // arguments contains the value the extension provides in [NSExtensionContext completeRequestReturningItems:completion:].
    // In this example, the extension provides a color as a returning item.
    document.body.style.backgroundColor = arguments["bgColor"];
}
};

// The JavaScript file must contain a global object named "ExtensionPreprocessingJS".
var ExtensionPreprocessingJS = new MyExtensionJavaScriptClass;
//allert("HI");