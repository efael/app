use messages::prelude::Address;
use rinf::DartSignal;

pub trait EasyListener
where
    Self: Sized + messages::prelude::Actor,
{
    fn spawn_listener<F>(&mut self, task: F)
    where
        F: Future<Output = ()>,
        F: Send + 'static;

    fn get_address(&self) -> Address<Self>;

    fn listen_to<Signal>(&mut self)
    where
        Self: messages::prelude::Notifiable<Signal>,
        Signal: DartSignal + Send + 'static,
    {
        let mut address = self.get_address();
        self.spawn_listener(async move {
            let receiver = Signal::get_dart_signal_receiver();
            while let Some(signal_pack) = receiver.recv().await {
                let _ = address.notify(signal_pack.message).await;
            }
        })
    }
}
