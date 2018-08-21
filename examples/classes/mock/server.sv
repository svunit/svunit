virtual class server;
  typedef enum { ACTION0, ACTION1 } action_e;

  pure virtual function void perform(action_e action, int value = 0);
endclass
