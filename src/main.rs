use once_cell::sync::Lazy;
use rutie::{Class, Encoding, Object, RString, VM};
extern crate dlopen;
use dlopen::raw::Library;
use std::{io::Write, path::Path};
use tempfile::NamedTempFile;

static mut FILES: Lazy<Vec<&[u8]>> = Lazy::new(|| { vec![/*replace*/]});

fn main() {
    // println!("hello")
    unsafe {
        VM::init();
        VM::init_loadpath();
        let loaded_lib_names = vec![/*replace*/];
        let mut libs: Vec<Library> = vec![];
        for (i, lib_file) in FILES.iter().enumerate() {
            let mut file = NamedTempFile::new().unwrap();
            file.write_all(*lib_file).unwrap();
            let lib = Library::open(file.path()).unwrap();
            let path = Path::new(loaded_lib_names[i]);
            let file_name = path.file_stem().unwrap();
            let init_func_name = format!("{}{}", "Init_", file_name.to_str().unwrap());
            let func: unsafe extern "C" fn() = lib.symbol(&init_func_name).unwrap();
            libs.push(lib);
            func();
            file.close().unwrap();
        }

        let iseq_class = Class::from_existing("RubyVM").get_nested_class("InstructionSequence");
        let file = include_bytes!(/*replace*/);
        let src = RString::from_bytes(file, &Encoding::us_ascii());
        let iseq = iseq_class.send("load_from_binary", &[src.to_any_object()]);
        iseq.send("eval", &[]);
    };
}
