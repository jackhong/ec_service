Sequel.migration do
  up do
    create_table(:experiments) do
      primary_key :id
      String :name, null: false
      String :status
      String :oedl
      String :props
      String :graph_descs
      String :logs
    end
  end

  down do
    drop_table(:experiments)
  end
end
