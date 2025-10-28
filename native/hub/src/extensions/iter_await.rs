use tokio::task::JoinSet;

pub struct IterAwait<I>
where
    I: Iterator,
    I::Item: Future + Send + 'static,
    <I::Item as Future>::Output: Send + 'static,
{
    iter: I,
}

#[allow(dead_code)]
impl<I> IterAwait<I>
where
    I: Iterator,
    I::Item: Future + Send + 'static,
    <I::Item as Future>::Output: Send + 'static,
{
    pub fn new(iter: I) -> Self {
        Self { iter }
    }

    pub fn join_set(self) -> JoinSet<<I::Item as Future>::Output> {
        self.iter.fold(JoinSet::new(), |mut tasks, task| {
            tasks.spawn(task);
            tasks
        })
    }

    pub async fn join_all_sorted(self) -> Vec<<I::Item as Future>::Output> {
        let mut values = self
            .iter
            .enumerate()
            .fold(JoinSet::new(), |mut tasks, (index, task)| {
                tasks.spawn(async move { (index, task.await) });
                tasks
            })
            .join_all()
            .await;

        values.sort_by(|a, b| a.0.cmp(&b.0));

        values.into_iter().map(|r| r.1).collect()
    }
}
