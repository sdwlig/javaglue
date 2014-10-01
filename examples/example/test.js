try {
importPackage(org.javaglue);
t = new Test();
print(t);
t.setString("Hi");
p = t.getCString();
s = t.toString(p);
print(s);

print("0");

t.setu8(5);
t.seti8(6);
var i8p = Scalar.newint8(256);
Scalar.del(i8p);
print(".5");

  var t2 = new Test2();
print("1");
  var et = EnumTest.Second;
print("2");
  t2.setet(et);
print("3");
  var et2 = EnumTest.First;
print("4");
  var etp = new EnumTestPtr();
print("5");
  etp.set(0);
print("6");
  print(etp.addr());
  print(etp.et);
  t2.getetp(etp.addr());
print("7");
  print(etp.et);
print("8");

var si8 = new VarInt8(5);
var si = new VarInt(33);
var si32 = new VarInt32();
print(si.val);
t2.setrefi(si.addr());
print(si.val);

var test0 = new Test0();
print("Default value of test0.i is 100.");
print(test0.i);
test0.i = 44;
print("Set to 44.");
print(test0.i);
print("Test0.i member of Test, should default to 100.");
t.gett0(test0);
print(test0.i);
test0.i = 200;
t.sett0(test0);
var t0 = new Test0();
t.gett0(t0);
print("Return by value t0.  t0.i was set to 200.");
print(t0.i);

} catch (e) {
    print("Exception");
    // e.rhinoException.printStackTrace();
}
