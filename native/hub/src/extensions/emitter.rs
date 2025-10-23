use messages::prelude::{Address, Notifiable};
use rinf::DartSignal;

pub trait Emitter<A> {
    fn emit<Signal>(&mut self, request: Signal)
    where
        A: Notifiable<Signal>,
        Signal: DartSignal + Send + 'static;
}

impl<A> Emitter<A> for Address<A> {
    fn emit<Signal>(&mut self, request: Signal)
    where
        A: Notifiable<Signal>,
        Signal: DartSignal + Send + 'static,
    {
        let mut addr = self.clone();
        tokio::spawn(async move {
            let _ = addr.notify(request).await;
        });
    }
}
