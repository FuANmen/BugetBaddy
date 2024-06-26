/*************************************************************************
 *
 * Copyright 2016 Realm Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 **************************************************************************/

#ifndef REALM_UTIL_FILE_HPP
#define REALM_UTIL_FILE_HPP

#include <cstddef>
#include <cstdint>
#include <ctime>
#include <functional>
#include <memory>
#include <streambuf>
#include <string>

#ifdef _WIN32
#include <Windows.h>
#else
#include <dirent.h> // POSIX.1-2001
#include <sys/stat.h>
#endif

#include <realm/exceptions.hpp>
#include <realm/util/assert.hpp>
#include <realm/util/features.h>
#include <realm/util/function_ref.hpp>
#include <realm/util/safe_int_ops.hpp>
#include <realm/utilities.hpp>

#if defined(_MSVC_LANG) // compiling with MSVC
#include <filesystem>
#define REALM_HAVE_STD_FILESYSTEM 1
#else
#define REALM_HAVE_STD_FILESYSTEM 0
#endif

#if REALM_APPLE_DEVICE && !REALM_TVOS && !REALM_MACCATALYST
#define REALM_FILELOCK_EMULATION
#endif

namespace realm::util {

class EncryptedFile;
class EncryptedFileMapping;
class WriteObserver;

/// Create the specified directory in the file system.
///
/// \throw FileAccessError If the directory could not be created. If
/// the reason corresponds to one of the exception types that are
/// derived from FileAccessError, the derived exception type is
/// thrown (as long as the underlying system provides the information
/// to unambiguously distinguish that particular reason).
void make_dir(const std::string& path);

/// Same as make_dir() except that this one returns false, rather than throwing
/// an exception, if the specified directory already existed. If the directory
/// did not already exist and was newly created, this returns true.
bool try_make_dir(const std::string& path);

/// Recursively create each of the directories in the given absolute path. Existing directories are ignored, and
/// FileAccessError is thrown for any other errors that occur.
void make_dir_recursive(std::string path);

/// Remove the specified empty directory path from the file system. It is an
/// error if the specified path is not a directory, or if it is a nonempty
/// directory. In so far as the specified path is a directory, std::remove(const
/// char*) is equivalent to this function.
///
/// \throw FileAccessError If the directory could not be removed. If the
/// reason corresponds to one of the exception types that are derived from
/// FileAccessError, the derived exception type is thrown (as long as the
/// underlying system provides the information to unambiguously distinguish that
/// particular reason).
void remove_dir(const std::string& path);

/// Same as remove_dir() except that this one returns false, rather
/// than throwing an exception, if the specified directory did not
/// exist. If the directory did exist, and was deleted, this function
/// returns true.
bool try_remove_dir(const std::string& path);

/// Remove the specified directory after removing all its contents. Files
/// (nondirectory entries) will be removed as if by a call to File::remove(),
/// and empty directories as if by a call to remove_dir().
///
/// Returns false if the directory already did not exist and true otherwise.
///
/// \throw FileAccessError If the directory existed and removal of the directory or any of its contents fails.
///
/// remove_dir_recursive() assumes that no other process or thread is making
/// simultaneous changes in the directory.
bool try_remove_dir_recursive(const std::string& path);

/// Create a new unique directory for temporary files. The absolute
/// path to the new directory is returned without a trailing slash.
std::string make_temp_dir();

/// Create a new temporary file.
std::string make_temp_file(const char* prefix);

size_t page_size();

/// This class provides a RAII abstraction over the concept of a file
/// descriptor (or file handle).
///
/// Locks are automatically and immediately released when the File
/// instance is closed.
///
/// You can use CloseGuard and UnlockGuard to acheive exception-safe
/// closing or unlocking prior to the File instance being detroyed.
///
/// A single File instance must never be accessed concurrently by
/// multiple threads.
///
/// You can write to a file via an std::ostream as follows:
///
/// \code{.cpp}
///
///   File::Streambuf my_streambuf(&my_file);
///   std::ostream out(&my_strerambuf);
///   out << 7945.9;
///
/// \endcode
class File {
public:
    enum Mode {
        mode_Read,   ///< access_ReadOnly,  create_Never             (fopen: rb)
        mode_Update, ///< access_ReadWrite, create_Never             (fopen: rb+)
        mode_Write,  ///< access_ReadWrite, create_Auto, flag_Trunc  (fopen: wb+)
        mode_Append  ///< access_ReadWrite, create_Auto, flag_Append (fopen: ab+)
    };

    /// Equivalent to calling open(std::string_view, Mode) on a
    /// default constructed instance.
    explicit File(std::string_view path, Mode = mode_Read);

    /// Create an instance that is not initially attached to an open
    /// file.
    File();
    ~File() noexcept;

    File(File&&) noexcept;
    File& operator=(File&&) noexcept;

    // Disable copying by l-value. Copying an open file will create a scenario
    // where the same file descriptor will be opened once but closed twice.
    File(const File&) = delete;
    File& operator=(const File&) = delete;

    /// Calling this function on an instance that is already attached
    /// to an open file has undefined behavior.
    ///
    /// \throw AccessError If the file could not be opened. If the
    /// reason corresponds to one of the exception types that are
    /// derived from AccessError, the derived exception type is thrown
    /// (as long as the underlying system provides the information to
    /// unambiguously distinguish that particular reason).
    void open(std::string_view path, Mode = mode_Read);

    /// This function is idempotent, that is, it is valid to call it
    /// regardless of whether this instance currently is attached to
    /// an open file.
    void close() noexcept;

    /// Check whether this File instance is currently attached to an
    /// open file.
    bool is_attached() const noexcept;

    enum AccessMode {
        access_ReadOnly,
        access_ReadWrite,
    };

    enum CreateMode {
        create_Auto,  ///< Create the file if it does not already exist.
        create_Never, ///< Fail if the file does not already exist.
        create_Must   ///< Fail if the file already exists.
    };

    enum {
        flag_Trunc = 1, ///< Truncate the file if it already exists.
        flag_Append = 2 ///< Move to end of file before each write.
    };

    /// See open(std::string_view, Mode).
    ///
    /// Specifying access_ReadOnly together with a create mode that is
    /// not create_Never, or together with a non-zero \a flags
    /// argument, results in undefined behavior. Specifying flag_Trunc
    /// together with create_Must results in undefined behavior.
    void open(std::string_view path, AccessMode, CreateMode, int flags);

    /// Same as open(path, access_ReadWrite, create_Auto, 0), except
    /// that this one returns an indication of whether a new file was
    /// created, or an existing file was opened.
    void open(std::string_view path, bool& was_created);

    /// Plays the same role as off_t in POSIX
    typedef int_fast64_t SizeType;

    /// Read data into the specified buffer and return the number of
    /// bytes read. If the returned number of bytes is less than \a
    /// size, then the end of the file has been reached.
    ///
    /// Calling this function on an instance, that is not currently
    /// attached to an open file, has undefined behavior.
    size_t read(SizeType pos, char* data, size_t size);
    static size_t read_static(FileDesc fd, SizeType pos, char* data, size_t size);

    /// Write the specified data to this file.
    ///
    /// Calling this function on an instance, that is not currently
    /// attached to an open file, has undefined behavior.
    ///
    /// Calling this function on an instance, that was opened in
    /// read-only mode, has undefined behavior.
    void write(SizeType pos, const char* data, size_t size);
    static void write_static(FileDesc fd, SizeType pos, const char* data, size_t size);

    // Tells current file pointer of fd
    SizeType get_file_pos();

    /// Calls write(s.data(), s.size()).
    void write(SizeType pos, std::string_view s)
    {
        write(pos, s.data(), s.size());
    }

    /// Calls read(data, N).
    template <size_t N>
    size_t read(SizeType pos, char (&data)[N])
    {
        return read(pos, data, N);
    }

    /// Calls write(data(), N).
    template <size_t N>
    void write(SizeType pos, const char (&data)[N])
    {
        write(pos, data, N);
    }

    /// Calling this function on an instance that is not attached to
    /// an open file has undefined behavior.
    SizeType get_size() const;
    static SizeType get_size_static(FileDesc fd);
    static SizeType get_size_static(const std::string& path);

    /// If this causes the file to grow, then the new section will
    /// have undefined contents. Setting the size with this function
    /// does not necessarily allocate space on the target device. If
    /// you want to ensure allocation, call alloc(). Calling this
    /// function will generally affect the read/write offset
    /// associated with this File instance.
    ///
    /// Calling this function on an instance that is not attached to
    /// an open file has undefined behavior. Calling this function on
    /// a file that is opened in read-only mode, is an error.
    void resize(SizeType);

    /// Same effect as prealloc_if_supported(original_size, new_size);
    ///
    /// The downside is that this function is not guaranteed to have
    /// atomic behaviour on all systems, that is, two processes, or
    /// two threads should never call this function concurrently for
    /// the same underlying file even though they access the file
    /// through distinct File instances.
    ///
    /// \sa prealloc_if_supported()
    void prealloc(SizeType new_size);

    /// When supported by the system, allocate space on the target
    /// device for the specified region of the file. If the region
    /// extends beyond the current end of the file, the file size is
    /// increased as necessary.
    ///
    /// On systems that do not support this operation, this function
    /// has no effect. You may call is_prealloc_supported() to
    /// determine if it is supported on your system.
    ///
    /// Calling this function on an instance, that is not attached to
    /// an open file, has undefined behavior. Calling this function on
    /// a file, that is opened in read-only mode, is an error.
    ///
    /// This function is guaranteed to have atomic behaviour, that is,
    /// there is never any risk of the file size being reduced even
    /// with concurrently executing invocations.
    ///
    /// \sa prealloc()
    /// \sa is_prealloc_supported()
    bool prealloc_if_supported(SizeType offset, SizeType size);

    /// See prealloc_if_supported().
    static bool is_prealloc_supported();

    /// Reposition the read/write offset of this File
    /// instance. Distinct File instances have separate independent
    /// offsets, as long as the cucrrent process is not forked.
    void seek(SizeType);
    static void seek_static(FileDesc, SizeType);

    /// Flush in-kernel buffers to disk. This blocks the caller until the
    /// synchronization operation is complete. On POSIX systems this function
    /// calls `fsync()`. On Apple platforms if calls `fcntl()` with command
    /// `F_FULLFSYNC`.
    void sync();

    /// Issue a write barrier which forbids ordering writes after this call
    /// before writes performed before this call. Equivalent to `sync()` on
    /// non-Apple platforms.
    void barrier();

    /// Place an exclusive lock on this file. This blocks the caller
    /// until all other locks have been released.
    ///
    /// Locks acquired on distinct File instances have fully recursive
    /// behavior, even if they are acquired in the same process (or
    /// thread) and are attached to the same underlying file.
    ///
    /// Calling this function on an instance that is not attached to
    /// an open file, or on an instance that is already locked has
    /// undefined behavior.
    void lock();

    /// Non-blocking version of `lock()`. Returns true if the lock was acquired
    /// and false otherwise.
    bool try_lock();

    /// Release a previously acquired lock on this file which was acquired with
    /// `lock()` or `try_lock()`. Calling this without holding the lock or
    /// while holding a lock acquired with one of the `rw` functions is
    /// undefined behavior.
    void unlock() noexcept;

    /// Place an shared lock on this file. This blocks the caller
    /// until all other locks have been released.
    ///
    /// Locks acquired on distinct File instances have fully recursive
    /// behavior, even if they are acquired in the same process (or
    /// thread) and are attached to the same underlying file.
    ///
    /// Calling this function on an instance that is not attached to an open
    /// file, on an instance that is already locked, or on a file which
    /// `lock()` (rather than `try_rw_lock_exclusive()` has been called on has
    /// undefined behavior.
    void rw_lock_shared();

    /// Attempt to place an exclusive lock on this file. Returns true if the
    /// lock could be acquired, and false if an exclusive or shared lock exists
    /// for the file.
    ///
    /// Locks acquired on distinct File instances have fully recursive
    /// behavior, even if they are acquired in the same process (or
    /// thread) and are attached to the same underlying file.
    ///
    /// Calling this function on an instance that is not attached to
    /// an open file, or on an instance that is already locked has
    /// undefined behavior.
    bool try_rw_lock_exclusive();

    /// Non-blocking version of lock_shared(). Returns true iff it
    /// succeeds.
    bool try_rw_lock_shared();

    /// Release a previously acquired read-write lock on this file acquired
    /// with `rw_lock_shared()`, `try_rw_lock_exclusive()` or
    /// `try_rw_lock_shared()`. Calling this after a call to `lock()` or
    /// without holding the lock is undefined behavior.
    void rw_unlock() noexcept;

    /// Set the encryption key used for this file. Must be called before any
    /// mappings are created or any data is read from or written to the file.
    ///
    /// \param key A 64-byte encryption key, or null to disable encryption.
    void set_encryption_key(const char* key);

    EncryptedFile* get_encryption() const noexcept;

    /// Set the path used for emulating file locks. If not set explicitly,
    /// the emulation will use the path of the file itself suffixed by ".fifo"
    void set_fifo_path(const std::string& fifo_dir_path, const std::string& fifo_file_name);

    /// Map this file into memory. The file is mapped as shared
    /// memory. This allows two processes to interact under exatly the
    /// same rules as applies to the interaction via regular memory of
    /// multiple threads inside a single process.
    ///
    /// This File instance does not need to remain in existence after
    /// the mapping is established.
    ///
    /// Multiple concurrent mappings may be created from the same File
    /// instance.
    ///
    /// Specifying access_ReadWrite for a file that is opened in
    /// read-only mode, is an error.
    ///
    /// Calling this function on an instance that is not attached to
    /// an open file, or one that is attached to an empty file has
    /// undefined behavior.
    ///
    /// Calling this function with a size that is greater than the
    /// size of the file has undefined behavior.

    /// Check whether the specified file or directory exists. Note
    /// that a file or directory that resides in a directory that the
    /// calling process has no access to, will necessarily be reported
    /// as not existing.
    static bool exists(const std::string& path);

    /// Get the time of last modification made to the file
    static time_t last_write_time(const std::string& path);

    /// Get freespace (in bytes) of filesystem containing path
    static SizeType get_free_space(const std::string& path);

    /// Check whether the specified path exists and refers to a directory. If
    /// the referenced file system object resides in an inaccessible directory,
    /// this function returns false.
    static bool is_dir(const std::string& path);

    /// Remove the specified file path from the file system. It is an error if
    /// the specified path is a directory. If the specified file is a symbolic
    /// link, the link is removed, leaving the liked file intact. In so far as
    /// the specified path is not a directory, std::remove(const char*) is
    /// equivalent to this function.
    ///
    /// The specified file must not be open by the calling process. If
    /// it is, this function has undefined behaviour. Note that an
    /// open memory map of the file counts as "the file being open".
    ///
    /// \throw AccessError If the specified directory entry could not
    /// be removed. If the reason corresponds to one of the exception
    /// types that are derived from AccessError, the derived exception
    /// type is thrown (as long as the underlying system provides the
    /// information to unambiguously distinguish that particular
    /// reason).
    static void remove(const std::string& path);

    /// Same as remove() except that this one returns false, rather
    /// than throwing an exception, if the specified file does not
    /// exist. If the file did exist, and was deleted, this function
    /// returns true.
    static bool try_remove(const std::string& path);

    /// Change the path of a directory entry. This can be used to
    /// rename a file, and/or to move it from one directory to
    /// another. This function is equivalent to std::rename(const
    /// char*, const char*).
    ///
    /// \throw AccessError If the path of the directory entry could
    /// not be changed. If the reason corresponds to one of the
    /// exception types that are derived from AccessError, the derived
    /// exception type is thrown (as long as the underlying system
    /// provides the information to unambiguously distinguish that
    /// particular reason).
    static void move(const std::string& old_path, const std::string& new_path);

    /// Copy the file at the specified origin path to the specified target path.
    static bool copy(const std::string& origin_path, const std::string& target_path, bool overwrite_existing = true);

    /// Check whether two open file descriptors refer to the same
    /// underlying file, that is, if writing via one of them, will
    /// affect what is read from the other. In UNIX this boils down to
    /// comparing inode numbers.
    ///
    /// Both instances have to be attached to open files. If they are
    /// not, this function has undefined behavior.
    bool is_same_file(const File&) const;
    static bool is_same_file_static(FileDesc f1, FileDesc f2, const std::string& path1, const std::string& path2);

    static FileDesc dup_file_desc(FileDesc fd);

    /// Resolve the specified path against the specified base directory.
    ///
    /// If \a path is absolute, or if \a base_dir is empty, \p path is returned
    /// unmodified, otherwise \a path is resolved against \a base_dir.
    ///
    /// Examples (assuming POSIX):
    ///
    ///    resolve("file", "dir")        -> "dir/file"
    ///    resolve("../baz", "/foo/bar") -> "/foo/baz"
    ///    resolve("foo", ".")           -> "./foo"
    ///    resolve(".", "/foo/")         -> "/foo"
    ///    resolve("..", "foo")          -> "."
    ///    resolve("../..", "foo")       -> ".."
    ///    resolve("..", "..")           -> "../.."
    ///    resolve("", "")               -> "."
    ///    resolve("", "/")              -> "/."
    ///    resolve("..", "/")            -> "/."
    ///    resolve("..", "foo//bar")     -> "foo"
    ///
    /// This function does not access the file system.
    ///
    /// \param path The path to be resolved. An empty string produces the same
    /// result as as if "." was passed. The result has a trailing directory
    /// separator (`/`) if, and only if this path has a trailing directory
    /// separator.
    ///
    /// \param base_dir The base directory path, which may be relative or
    /// absolute. A final directory separator (`/`) is optional. The empty
    /// string is interpreted as a relative path.
    static std::string resolve(const std::string& path, const std::string& base_dir);

    /// Same effect as std::filesystem::path::parent_path().
    static std::string parent_dir(const std::string& path);

    using ForEachHandler = util::FunctionRef<bool(const std::string& file, const std::string& dir)>;

    /// Scan the specified directory recursivle, and report each file
    /// (nondirectory entry) via the specified handler.
    ///
    /// The first argument passed to the handler is the name of a file (not the
    /// whole path), and the second argument is the directory in which that file
    /// resides. The directory will be specified as a path, and relative to \a
    /// dir_path. The directory will be the empty string for files residing
    /// directly in \a dir_path.
    ///
    /// If the handler returns false, scanning will be aborted immediately, and
    /// for_each() will return false. Otherwise for_each() will return true.
    ///
    /// Scanning is done as if by a recursive set of DirScanner objects.
    static bool for_each(const std::string& dir_path, ForEachHandler handler);

    struct UniqueID {
#ifdef _WIN32 // Windows version
        FILE_ID_INFO id_info;
#else
        UniqueID()
            : device(0)
            , inode(0)
        {
        }
        UniqueID(dev_t d, ino_t i)
            : device(d)
            , inode(i)
        {
        }
        // NDK r10e has a bug in sys/stat.h dev_t ino_t are 4 bytes,
        // but stat.st_dev and st_ino are 8 bytes. So we just use uint64 instead.
        dev_t device;
        uint_fast64_t inode;
#endif
    };
    // Return the file descriptor for the file
    FileDesc get_descriptor() const;
    // Return the path of the open file, or an empty string if
    // this file has never been opened.
    std::string get_path() const;

    // Return none if the file doesn't exist. Throws on other errors.
    // If the file does exist but has a size of zero, the file may be resized
    // to force the file system to allocate a unique id.
    static std::optional<UniqueID> get_unique_id(const std::string& path);

    // Return the unique id for the file descriptor. Throws if the underlying stat operation fails.
    static UniqueID get_unique_id(FileDesc file, const std::string& debug_path);

    template <class>
    class Map;

    class CloseGuard;
    class UnlockGuard;
    class UnmapGuard;

    class Streambuf;

private:
#ifdef _WIN32
    static inline const HANDLE invalid_fd = INVALID_HANDLE_VALUE;
#else
    static inline const int invalid_fd = -1;
#endif

    FileDesc m_fd = invalid_fd;
    bool m_have_lock = false; // Only valid when m_fd is not null
#ifdef REALM_FILELOCK_EMULATION
    bool m_has_exclusive_lock = false;
    int m_pipe_fd = -1; // -1 if no pipe has been allocated for emulation
    std::string m_fifo_dir_path;
    std::string m_fifo_path;
#endif
    std::unique_ptr<util::EncryptedFile> m_encryption;
    std::string m_path;

    bool lock(bool exclusive, bool non_blocking);
    bool rw_lock(bool exclusive, bool non_blocking);
    void open_internal(std::string_view path, AccessMode, CreateMode, int flags, bool* success);

#ifdef REALM_FILELOCK_EMULATION
    bool has_shared_lock() const noexcept
    {
        return m_pipe_fd != -1;
    }
#endif

    struct MapBase {
        void* m_addr = nullptr;
        mutable size_t m_size = 0;
        size_t m_reservation_size = 0;
        uint64_t m_offset = 0;
        FileDesc m_fd = invalid_fd;
        AccessMode m_access_mode = access_ReadOnly;

        MapBase() noexcept;
        ~MapBase() noexcept;

        // Disable copying. Copying an opened MapBase will create a scenario
        // where the same memory will be mapped once but unmapped twice.
        MapBase(const MapBase&) = delete;
        MapBase& operator=(const MapBase&) = delete;

        MapBase(MapBase&& other) noexcept;
        MapBase& operator=(MapBase&& other) noexcept;

        void map(const File&, AccessMode, size_t size, SizeType offset = 0, util::WriteObserver* observer = nullptr);
        // reserve address space for later mapping operations.
        // returns false if reservation can't be done.
        bool try_reserve(const File&, AccessMode, size_t size, SizeType offset = 0,
                         util::WriteObserver* observer = nullptr);
        void unmap() noexcept;
        // fully update any process shared representation (e.g. buffer cache).
        // other processes will be able to see changes, but a full platform crash
        // may loose data
        void flush(bool skip_validate = false);
        // try to extend the mapping in-place. Virtual address space must have
        // been set aside earlier by a call to reserve()
        bool try_extend_to(size_t size) noexcept;
        // fully synchronize any underlying storage. After completion, a full platform
        // crash will *not* have lost data.
        void sync();
#if REALM_ENABLE_ENCRYPTION
        mutable std::unique_ptr<util::EncryptedFileMapping> m_encrypted_mapping;
        util::EncryptedFileMapping* get_encrypted_mapping() const
        {
            return m_encrypted_mapping.get();
        }
#else
        util::EncryptedFileMapping* get_encrypted_mapping() const
        {
            return nullptr;
        }
#endif
    };
};

/// This class provides a RAII abstraction over the concept of a
/// memory mapped file.
///
/// Once created, the Map instance makes no reference to the File
/// instance that it was based upon, and that File instance may be
/// destroyed before the Map instance is destroyed.
///
/// Multiple concurrent mappings may be created from the same File
/// instance.
///
/// You can use UnmapGuard to acheive exception-safe unmapping prior
/// to the Map instance being detroyed.
///
/// A single Map instance must never be accessed concurrently by
/// multiple threads.
template <class T>
class File::Map : private MapBase {
public:
    /// Equivalent to calling map() on a default constructed instance.
    explicit Map(const File&, AccessMode = access_ReadOnly, size_t size = sizeof(T),
                 util::WriteObserver* observer = nullptr);

    explicit Map(const File&, SizeType offset, AccessMode = access_ReadOnly, size_t size = sizeof(T),
                 util::WriteObserver* observer = nullptr);

    /// Create an instance that is not initially attached to a memory
    /// mapped file.
    Map() noexcept = default;

    // Disable copying. Copying an opened Map will create a scenario
    // where the same memory will be mapped once but unmapped twice.
    Map(const Map&) = delete;
    Map& operator=(const Map&) = delete;

    /// Move the mapping from another Map object to this Map object
    File::Map<T>& operator=(File::Map<T>&& other) noexcept = default;
    Map(Map&& other) noexcept = default;

    /// See File::map().
    ///
    /// Calling this function on a Map instance that is already
    /// attached to a memory mapped file has undefined behavior. The
    /// returned pointer is the same as what will subsequently be
    /// returned by get_addr().
    T* map(const File&, AccessMode = access_ReadOnly, size_t size = sizeof(T), SizeType offset = 0,
           util::WriteObserver* observer = nullptr);

    /// See File::unmap(). This function is idempotent, that is, it is
    /// valid to call it regardless of whether this instance is
    /// currently attached to a memory mapped file.
    void unmap() noexcept;

    bool try_reserve(const File&, AccessMode a = access_ReadOnly, size_t size = sizeof(T), SizeType offset = 0,
                     util::WriteObserver* observer = nullptr);

    /// The same as unmap(old_addr, old_size) followed by map(a,
    /// new_size, map_flags), but more efficient on some systems.
    ///
    ///
    /// Calling this function on a Map instance that is not currently attached
    /// to a memory mapped file is equivalent to calling map(). The returned
    /// pointer is the same as what will subsequently be returned by
    /// get_addr().
    ///
    /// If this function throws, the old address range will remain
    /// mapped.
    T* remap(const File&, AccessMode = access_ReadOnly, size_t size = sizeof(T));

    /// Try to extend the existing mapping to a given size
    bool try_extend_to(size_t size) noexcept;

    /// See File::sync_map().
    ///
    /// Calling this function on an instance that is not currently
    /// attached to a memory mapped file, has undefined behavior.
    using MapBase::flush;
    using MapBase::sync;

    /// Check whether this Map instance is currently attached to a
    /// memory mapped file.
    bool is_attached() const noexcept;

    /// Returns a pointer to the beginning of the memory mapped file,
    /// or null if this instance is not currently attached.
    T* get_addr() const noexcept;

    /// Returns the size of the mapped region, or zero if this
    /// instance does not currently refer to a memory mapped
    /// file. When this instance refers to a memory mapped file, the
    /// returned value will always be identical to the size passed to
    /// the constructor or to map().
    size_t get_size() const noexcept;

    /// Release the currently attached memory mapped file from this
    /// Map instance. The address range may then be unmapped later by
    /// a call to File::unmap().
    T* release() noexcept;

    bool is_writeable() const noexcept
    {
        return m_access_mode == access_ReadWrite;
    }

    /// Get the encrypted file mapping corresponding to this mapping
    using MapBase::get_encrypted_mapping;

    friend class UnmapGuard;
};


class File::CloseGuard {
public:
    CloseGuard(File& f) noexcept
        : m_file(&f)
    {
    }
    ~CloseGuard() noexcept
    {
        if (m_file)
            m_file->close();
    }
    void release() noexcept
    {
        m_file = nullptr;
    }
    // Disallow the default implementation of copy/assign, this is not how this
    // class is intended to be used. For example we could get unexpected
    // behaviour if one CloseGuard is copied and released but the other is not.
    CloseGuard(const CloseGuard&) = delete;
    CloseGuard& operator=(const CloseGuard&) = delete;

private:
    File* m_file;
};


class File::UnlockGuard {
public:
    UnlockGuard(File& f) noexcept
        : m_file(&f)
    {
    }
    ~UnlockGuard() noexcept
    {
        if (m_file)
            m_file->rw_unlock();
    }
    void release() noexcept
    {
        m_file = nullptr;
    }
    // Disallow the default implementation of copy/assign, this is not how this
    // class is intended to be used. For example we could get unexpected
    // behaviour if one UnlockGuard is copied and released but the other is not.
    UnlockGuard(const UnlockGuard&) = delete;
    UnlockGuard& operator=(const UnlockGuard&) = delete;

private:
    File* m_file;
};


class File::UnmapGuard {
public:
    template <class T>
    UnmapGuard(Map<T>& m) noexcept
        : m_map(&m)
    {
    }
    ~UnmapGuard() noexcept
    {
        if (m_map)
            m_map->unmap();
    }
    void release() noexcept
    {
        m_map = nullptr;
    }
    // Disallow the default implementation of copy/assign, this is not how this
    // class is intended to be used. For example we could get unexpected
    // behaviour if one UnmapGuard is copied and released but the other is not.
    UnmapGuard(const UnmapGuard&) = delete;
    UnmapGuard& operator=(const UnmapGuard&) = delete;

private:
    MapBase* m_map;
};


/// Only output is supported at this point.
class File::Streambuf : public std::streambuf {
public:
    explicit Streambuf(File*, size_t = 4096);
    ~Streambuf() noexcept;

    // Disable copying
    Streambuf(const Streambuf&) = delete;
    Streambuf& operator=(const Streambuf&) = delete;

private:
    File& m_file;
    std::unique_ptr<char[]> const m_buffer;

    int_type overflow(int_type) override;
    int sync() override;
    pos_type seekpos(pos_type, std::ios_base::openmode) override;
    void flush();
};

class DirScanner {
public:
    DirScanner(const std::string& path, bool allow_missing = false);
    ~DirScanner() noexcept;
    bool next(std::string& name);

private:
#ifndef _WIN32
    DIR* m_dirp;
#elif REALM_HAVE_STD_FILESYSTEM
    std::filesystem::directory_iterator m_iterator;
#endif
};


// Implementation:

inline void File::set_fifo_path(const std::string& fifo_dir_path, const std::string& fifo_file_name)
{
#ifdef REALM_FILELOCK_EMULATION
    m_fifo_dir_path = fifo_dir_path;
    m_fifo_path = fifo_dir_path + "/" + fifo_file_name;
#else
    static_cast<void>(fifo_dir_path);
    static_cast<void>(fifo_file_name);
#endif
}

inline void File::open(std::string_view path, Mode m)
{
    AccessMode a = access_ReadWrite;
    CreateMode c = create_Auto;
    int flags = 0;
    switch (m) {
        case mode_Read:
            a = access_ReadOnly;
            c = create_Never;
            break;
        case mode_Update:
            c = create_Never;
            break;
        case mode_Write:
            flags = flag_Trunc;
            break;
        case mode_Append:
            flags = flag_Append;
            break;
    }
    open(path, a, c, flags);
}

inline void File::open(std::string_view path, AccessMode am, CreateMode cm, int flags)
{
    open_internal(path, am, cm, flags, nullptr);
}


inline void File::open(std::string_view path, bool& was_created)
{
    while (1) {
        bool success;
        open_internal(path, access_ReadWrite, create_Must, 0, &success);
        if (success) {
            was_created = true;
            return;
        }
        open_internal(path, access_ReadWrite, create_Never, 0, &success);
        if (success) {
            was_created = false;
            return;
        }
    }
}

inline bool File::is_attached() const noexcept
{
    return m_fd != invalid_fd;
}

inline void File::rw_lock_shared()
{
    rw_lock(false, false);
}

inline bool File::try_rw_lock_exclusive()
{
    return rw_lock(true, true);
}

inline bool File::try_rw_lock_shared()
{
    return rw_lock(false, true);
}

inline void File::lock()
{
    lock(true, false);
}

inline bool File::try_lock()
{
    return lock(true, true);
}


template <class T>
inline File::Map<T>::Map(const File& f, AccessMode a, size_t size, util::WriteObserver* observer)
{
    map(f, a, size, 0, observer);
}

template <class T>
inline File::Map<T>::Map(const File& f, SizeType offset, AccessMode a, size_t size, util::WriteObserver* observer)
{
    map(f, a, size, offset, observer);
}

template <class T>
inline T* File::Map<T>::map(const File& f, AccessMode a, size_t size, SizeType offset, util::WriteObserver* observer)
{
    MapBase::map(f, a, size, offset, observer);
    return static_cast<T*>(m_addr);
}

template <class T>
inline bool File::Map<T>::try_reserve(const File& f, AccessMode a, size_t size, SizeType offset,
                                      util::WriteObserver* observer)
{
    return MapBase::try_reserve(f, a, size, offset, observer);
}

template <class T>
inline void File::Map<T>::unmap() noexcept
{
    MapBase::unmap();
}

template <class T>
inline T* File::Map<T>::remap(const File& f, AccessMode a, size_t size)
{
    // missing sync() here?
    unmap();
    map(f, a, size);
    return static_cast<T*>(m_addr);
}

template <class T>
inline bool File::Map<T>::try_extend_to(size_t size) noexcept
{
    return MapBase::try_extend_to(sizeof(T) * size);
}

template <class T>
inline bool File::Map<T>::is_attached() const noexcept
{
    return (m_addr != nullptr);
}

template <class T>
inline T* File::Map<T>::get_addr() const noexcept
{
    return static_cast<T*>(m_addr);
}

template <class T>
inline size_t File::Map<T>::get_size() const noexcept
{
    return m_addr ? m_size : 0;
}

template <class T>
inline T* File::Map<T>::release() noexcept
{
    T* addr = static_cast<T*>(m_addr);
    m_addr = nullptr;
    m_fd = invalid_fd;
    return addr;
}


inline File::Streambuf::Streambuf(File* f, size_t buffer_size)
    : m_file(*f)
    , m_buffer(new char[buffer_size])
{
    char* b = m_buffer.get();
    setp(b, b + buffer_size);
}

inline File::Streambuf::~Streambuf() noexcept
{
    try {
        if (m_file.is_attached())
            flush();
    }
    catch (...) {
        // Errors deliberately ignored
    }
}

inline File::Streambuf::int_type File::Streambuf::overflow(int_type c)
{
    flush();
    if (c == traits_type::eof())
        return traits_type::not_eof(c);
    *pptr() = traits_type::to_char_type(c);
    pbump(1);
    return c;
}

inline int File::Streambuf::sync()
{
    flush();
    return 0;
}

inline File::Streambuf::pos_type File::Streambuf::seekpos(pos_type pos, std::ios_base::openmode)
{
    flush();
    SizeType pos2 = 0;
    if (int_cast_with_overflow_detect(std::streamsize(pos), pos2))
        throw RuntimeError(ErrorCodes::RangeError, "Seek position overflow");
    m_file.seek(pos2);
    return pos;
}

inline void File::Streambuf::flush()
{
    size_t n = pptr() - pbase();
    if (n > 0) {
        SizeType pos = m_file.get_file_pos();
        m_file.write(pos, pbase(), n);
        setp(m_buffer.get(), epptr());
        m_file.seek(pos + n);
    }
}

inline bool operator==(const File::UniqueID& lhs, const File::UniqueID& rhs)
{
#ifdef _WIN32 // Windows version
    return lhs.id_info.VolumeSerialNumber == rhs.id_info.VolumeSerialNumber &&
           memcmp(&lhs.id_info.FileId, &rhs.id_info.FileId, sizeof(lhs.id_info.FileId)) == 0;
#else // POSIX version
    return lhs.device == rhs.device && lhs.inode == rhs.inode;
#endif
}

inline bool operator!=(const File::UniqueID& lhs, const File::UniqueID& rhs)
{
    return !(lhs == rhs);
}

inline bool operator<(const File::UniqueID& lhs, const File::UniqueID& rhs)
{
#ifdef _WIN32 // Windows version
    if (lhs.id_info.VolumeSerialNumber != rhs.id_info.VolumeSerialNumber)
        return lhs.id_info.VolumeSerialNumber < rhs.id_info.VolumeSerialNumber;
    return memcmp(&lhs.id_info.FileId, &rhs.id_info.FileId, sizeof(lhs.id_info.FileId)) < 0;
#else // POSIX version
    if (lhs.device < rhs.device)
        return true;
    if (lhs.device > rhs.device)
        return false;
    if (lhs.inode < rhs.inode)
        return true;
    return false;
#endif
}

inline bool operator>(const File::UniqueID& lhs, const File::UniqueID& rhs)
{
    return rhs < lhs;
}

inline bool operator<=(const File::UniqueID& lhs, const File::UniqueID& rhs)
{
    return !(lhs > rhs);
}

inline bool operator>=(const File::UniqueID& lhs, const File::UniqueID& rhs)
{
    return !(lhs < rhs);
}
} // namespace realm::util

#endif // REALM_UTIL_FILE_HPP
