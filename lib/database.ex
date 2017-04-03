use Amnesia

defdatabase Database do
  deftable Value

  deftable Value, [{ :id, autoincrement }, :key, :value, :last_updater], type: :ordered_set, index: [:key] do
    @type t :: %Value{id: non_neg_integer, key: String.t, value: String.t, last_updater: String.t}

    # this is a helper function to add a message to the user, using write
    # on the created records makes it write to the mnesia table
    # def add_value(self, content) do
    #   %Message{user_id: self.id, content: content} |> Message.write
    # end

    # # like above, but again with dirty operations, the bang methods are used
    # # thorough amnesia to be the dirty counterparts of the bang-less functions
    # def add_message!(self, content) do
    #   %Message{user_id: self.id, content: content} |> Message.write!
    # end

    # # this is a helper to fetch all messages for the user
    # def messages(self) do
    #   Message.read(self.id)
    # end

    # # like above, but with dirty operations
    # def messages!(self) do
    #   Message.read!(self.id)
    # end
  end
end