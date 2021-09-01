

/*
  Class: svunit_printer
  Singleton object with default info and error display implementation
 */
class svunit_printer;

  /*
    default printer
  */
  class default_printer;
    virtual function void info(string name, string msg);
      $display("INFO:  [%0t][%0s]: %s", $time, name, msg);
    endfunction
    virtual function void error(string name, string msg);
      $display("ERROR: [%0t][%0s]: %s", $time, name, msg);
    endfunction
    virtual function void lf();
      $display("");
    endfunction
  endclass

  typedef svunit_printer this_type;
  local static this_type _this;
  local default_printer _impl;

  local function new();
    default_printer default_impl = new();
    _impl = default_impl;
  endfunction

  static function this_type get();
    if(_this == null)
        _this = new();
    return _this;
  endfunction

  /*
    Method: set_implementation
    Overrides current printer implementation

    Parameters:
      impl - new printer implementation extended from default_printer
  */
  function void set_implementation(default_printer impl);
    _impl = impl;
  endfunction

  /*
    Method: info
    Wrapper for info method call from printer

    Parameters:
      name - name of test used for $display
      msg  - text to be displayed as info
  */
  static function void info(string name, string msg);
    this_type printer;
    printer = this_type::get();
    printer._impl.info(name, msg);
  endfunction

  /*
    Method: error
    Wrapper for error method call from printer

    Parameters:
      name - name of test used for $display
      msg  - text to be displayed as error
  */
  static function void error(string name, string msg);
    this_type printer;
    printer = this_type::get();
    printer._impl.error(name, msg);
  endfunction

  /*
    Method: lf
    Wrapper for lf method call from printer
  */
  static function void lf();
    this_type printer;
    printer = this_type::get();
    printer._impl.lf();
  endfunction

endclass

