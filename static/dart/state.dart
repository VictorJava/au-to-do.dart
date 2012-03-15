#library('state');

interface State {
  void push(String state);
  String pop();
}

class UIState implements State {
  List<String> states;
  
  UIState() {
    states = new List<String>();
  }
  
  void push(String state) {
    states.addLast(state);
    print('pushed ' + state);
  }
  
  String pop() {
    print('popped ' + states.last());
    return states.removeLast();
  }
}