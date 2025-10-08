use messages::prelude::Address;
use rinf::{DartSignal, RustSignal};

pub trait EasyListener
where
    Self: Sized + messages::prelude::Actor,
{
    fn spawn_listener<F>(&mut self, task: F)
    where
        F: Future<Output = ()>,
        F: Send + 'static;

    fn get_address(&self) -> Address<Self>;

    fn listen_to_notification<IN>(&mut self)
    where
        Self: messages::prelude::Notifiable<IN>,
        IN: DartSignal + Send + 'static,
    {
        let mut address = self.get_address();
        self.spawn_listener(async move {
            let receiver = IN::get_dart_signal_receiver();
            while let Some(signal_pack) = receiver.recv().await {
                let _ = address.notify(signal_pack.message).await;
            }
        })
    }

    fn listen_to_handler<IN>(&mut self)
    where
        Self: messages::prelude::Handler<IN>,
        IN: DartSignal + Send + 'static,
        <Self as messages::prelude::Handler<IN>>::Result:
            std::marker::Send + std::marker::Sync + RustSignal,
    {
        let mut address = self.get_address();
        self.spawn_listener(async move {
            let receiver = IN::get_dart_signal_receiver();
            while let Some(signal_pack) = receiver.recv().await {
                if let Ok(signal) = address.send(signal_pack.message).await {
                    signal.send_signal_to_dart();
                }
            }
        })
    }
}
