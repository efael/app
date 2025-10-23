use std::io::Write;

use tracing_subscriber::fmt::MakeWriter;

#[derive(Default)]
pub struct RinfWriter;

impl Write for RinfWriter {
    fn write(&mut self, buf: &[u8]) -> std::io::Result<usize> {
        let result = rinf::send_rust_signal("RinfOut", Vec::new(), buf.into());
        if let Err(err) = result
            && let Ok(buf) = String::from_utf8(buf.into())
        {
            println!("{}\n{}", err, buf);
        }

        Ok(buf.len())
    }

    fn flush(&mut self) -> std::io::Result<()> {
        Ok(())
    }
}

impl<'a> MakeWriter<'a> for RinfWriter {
    type Writer = RinfWriter;
    fn make_writer(&'a self) -> Self::Writer {
        Default::default()
    }
}
