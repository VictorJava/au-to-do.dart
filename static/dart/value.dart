// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/**
 * 
 */
class Value<T> {
  T _value;
  List<ChangeListener> _observers;

  Value(this._value);

  void addObserver(ChangeListener listener) {
    if (_observers == null) _observers = [];
    _observers.add(listener);
  }

  void noteChange() {
    if (_observers != null) {
      for (final observer in _observers) {
        observer();
      }
    }
  }

  void set v(T newValue) {
    _value = newValue;
    noteChange();
  }

  T get v() => _value;
  
  // TODO(jimhug): Weigh pros/cons of this convenience.
  String toString() => _value.toString();
}

/**
 *
 */
class ComputedValue<T> extends Value<T> {
  var _function;
  
  ComputedValue(List<Value> dependencies, this._function): super(null) {
    recompute();
    for (var dep in dependencies) {
      dep.addObserver(this.recompute);
    }
  }
  
  void recompute() {
    this.v = _function();
  }
}

class ListValue<T> implements List<T> {
  List<T> _items;
  List<ListChangeListener> _observers;
  
  ListValue() {
    _items = <T>[];
  }
  
  void addObserver(ListChangeListener listener) {
    if (_observers == null) _observers = [];
    _observers.add(listener);
  }
  
  void _noteAddAllChange(Collection<T> objs) {
    if (_observers != null) {
      _observers.forEach((o) => o.onAddAll(objs));
    }
  }

  void _noteAddChange(T obj) {
    if (_observers != null) {
      _observers.forEach((o) => o.onAdd(obj));
    }
  }
  
  void add(T value) {
    _items.add(value);
    _noteAddChange(value);
  }
  
  void addAll(Collection<T> values) {
    _items.addAll(values);
    _noteAddAllChange(values);
  }
}

// TODO(jimhug): Tradeoffs between creating closures needing classes???
typedef void ChangeListener();

interface ListChangeListener<T> {
  void onAdd(T obj);
  void onAddAll(Collection<T> objs);
}