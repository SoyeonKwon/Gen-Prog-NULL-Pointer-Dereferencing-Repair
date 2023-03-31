let feature : featureDescr = 
  { fd_name = "logwrites";              
    fd_enabled = ref true;
    fd_description = "generation of code to log memory writes";
    fd_extraopt = [];
    fd_doit = 
    (function (f: file) -> 
      let lwVisitor = new logWriteVisitor in
      visitCilFileSameGlobals lwVisitor f)
  } 
