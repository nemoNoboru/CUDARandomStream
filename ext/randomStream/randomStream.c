#include <ruby.h>
#include "lib/libsrc/randomStream.h"

randomStream* createRandomStream( int size );

static void killStream(void* self){
  destroyStream(self);
}

static VALUE newStream(VALUE klass){
  randomStream *stream = createRandomStream( 2048 );
  return Data_Wrap_Struct(klass, NULL, &killStream, stream);
}

static VALUE getrandom( VALUE self ){
  randomStream* s;
  Data_Get_Struct(self, randomStream, s);
  return rb_float_new( getRandom(s) );
}

void Init_randomStream(){
  VALUE class = rb_define_class("RandomStream",rb_cObject);
  rb_define_alloc_func(class,&newStream);
  rb_define_method(class,"getrandom", &getrandom ,0);
}
