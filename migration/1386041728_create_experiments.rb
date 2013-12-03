Sequel.migration do
  up do
    create_table(:experiments) do
      primary_key :id
      String :name, null: false
    end
  end

  down do
    drop_table(:experiments)
  end
end
