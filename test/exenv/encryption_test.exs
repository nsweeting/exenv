defmodule Exenv.EncryptionTest do
  use ExUnit.Case, async: false

  import Exenv.Support.Utils

  alias Exenv.Encryption

  setup do
    setup_temp!()
    on_exit(&teardown_temp!/0)
  end

  describe "create_master_key!/1" do
    test "will create a master.key file in the specified path" do
      key_path = (temp_path() <> "master.key") |> Encryption.create_master_key!()

      assert is_binary(key_path)
      assert File.exists?(key_path)
    end

    test "will create a valid key that can be used to encrypt data" do
      key_path = (temp_path() <> "master.key") |> Encryption.create_master_key!()
      key = File.read!(key_path)
      temp_file = temp_path() <> "secrets"
      File.write!(temp_file, "foobar")
      encrypted_text = Encryption.encrypt_secrets!(key, temp_file)
      decrypted_text = Encryption.decrypt_secrets!(key, encrypted_text)

      assert String.length(key) == 43
      refute encrypted_text == "foobar"
      assert decrypted_text == "foobar"
    end
  end

  describe "get_master_key!/1" do
    test "will fetch the MASTER_KEY env variable" do
      random_key = random_key()
      System.put_env("MASTER_KEY", random_key)

      assert Encryption.get_master_key!() == random_key
    end

    test "will raise an error if the master key env var is incorrect" do
      System.put_env("MASTER_KEY", "")

      assert_raise Exenv.Error, fn ->
        Encryption.get_master_key!()
      end
    end

    test "will fetch the master key from the provided path" do
      key_path = (temp_path() <> "master.key") |> Encryption.create_master_key!()
      key = File.read!(key_path)

      assert Encryption.get_master_key!(key_path) == key
    end

    test "will fetch the MASTER_KEY env variable if path is not valid" do
      random_key = random_key()
      System.put_env("MASTER_KEY", random_key)

      assert Encryption.get_master_key!(nil) == random_key
    end

    test "will raise an error if the file doesnt exist" do
      key_path = temp_path() <> random_key()

      assert_raise File.Error, fn ->
        Encryption.get_master_key!(key_path)
      end
    end
  end
end
