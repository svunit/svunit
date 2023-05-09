/* package private */ class string_utils;

  /* local */ typedef string array_of_string[];


  static function array_of_string split_by_char(string c, string s);
    string parts[$];
    int last_char_position = -1;

    if (c.len() != 1)
      $fatal(0, "Internal error: expected a single character string");

    for (int i = 0; i < s.len(); i++) begin
      if (i == s.len()-1)
        parts.push_back(s.substr(last_char_position+1, i));
      if (string'(s[i]) == c) begin
        parts.push_back(s.substr(last_char_position+1, i-1));
        last_char_position = i;
      end
    end

    return parts;
  endfunction

endclass
