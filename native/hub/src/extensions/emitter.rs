use messages::prelude::{Address, Notifiable};
use rinf::DartSignal;

pub trait Emitter<A> {
    fn emit<Signal>(&mut self, request: Signal)
    where
        A: Notifiable<Signal>,
        Signal: DartSignal + Send + 'static;
}

impl<A> Emitter<A> for Address<A> {
    #[tracing::instrument(skip(self, request))]
    fn emit<Signal>(&mut self, request: Signal)
    where
        A: Notifiable<Signal>,
        Signal: DartSignal + Send + 'static,
    {
        tracing::trace!("emitting {} globally", std::any::type_name_of_val(&request));
        let mut addr = self.clone();
        tokio::spawn(async move {
            let _ = addr.notify(request).await;
        });
    }
}
