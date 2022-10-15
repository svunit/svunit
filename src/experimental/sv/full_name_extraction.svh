/**
 * Extracts the full name of a test from the return value of $typename.
 *
 * The return value of $typename varies wildly across simulators.
 */
class full_name_extraction;

  function string get_full_name(string dollar_typename);
    string result = dollar_typename;
    result = strip_extends(result);
    result = rstrip(result);
    result = replace_double_colon_with_dot(result);
    return result;
  endfunction


  local function string strip_extends(string s);
    string sub_str = "extends ";
    int i;
    for (i = 0; i < s.len(); i++) begin
      if (s.substr(i, i+sub_str.len()-1) == sub_str)
        break;
    end

    // TODO Validate that we really found the sub string

    return s.substr(0, i-1);
  endfunction


  local function string rstrip(string s);
    int i;
    for (i = s.len()-1; i >= 0; i--)
      if (s[i] != " ")
        break;

    return s.substr(0, i);
  endfunction


  local function string replace_double_colon_with_dot(string s);
    string sub_str = "::";
    int i;
    for (i = 0; i < s.len(); i++) begin
      if (s.substr(i, i+sub_str.len()-1) == sub_str)
        break;
    end

    // TODO Validate that we really found the sub string

    return { s.substr(0, i-1), ".", s.substr(i+2, s.len()-1) };
  endfunction

endclass
