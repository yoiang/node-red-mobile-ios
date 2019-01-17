var fs = require('fs');
var mkdirp = require('mkdirp');
var when = require('when');

module.exports = {
    getTrackingFolder: function(folder) {
        return folder + "/process/tracking";
    },
    getTrackingFile: function(folder, withName) {
        return this.getTrackingFolder(folder) + "/" + withName + ".tracking";
    },
    createTrackingFolder: function(folder) {
        var path = this.getTrackingFolder(folder);

        return when.promise(function(resolve, reject) {
            mkdirp(path, function(error) {
                if (error) {
                    reject(error);
                } else {
                    resolve(path);
                }
            });        
        });
    },
    emptyTrackingFolder: function(folder, allowDoesNotExist) {
        var path = this.getTrackingFolder(folder);

        var removeFile = this.removeFile;

        return this.createTrackingFolder(folder)
        .then(function() {
            return when.promise(function(resolve, reject) {
                fs.readdir(path, function(error, files) {
                    if (error) {
                        reject(error);
                    } else {
                        resolve(files);
                    }
                });
            })
        })
        .then(function(files) {
            return when.join(files.filter(function(test) {
                return test !== "." && test !== "..";
            }).map(function(file) {
                return removeFile(path + "/" + file);
            }));
        });
    },
    createTrackingFile: function(folder, withName, allowExists) {
        var path = this.getTrackingFile(folder, withName);

        return this.createTrackingFolder(folder)
        .then(function() {

            // TODO: fs.access to test permission

            var flags = "w";
            if (!allowExists) {
                flags += "x";
            }

            return when.promise(function(resolve, reject) {
                fs.writeFile(
                    path, 
                    "Node-RED mobile tracking file", 
                    { flag: flags }, 
                    function (error) {
                        if (error) {
                            reject(error);
                        } else {
                            resolve(path);
                        }
                    }
                );
            });
        });
    },
    removeTrackingFile: function(folder, withName, allowDoesNotExist) {
        var path = this.getTrackingFile(folder, withName);

        var removeFile = this.removeFile;

        return this.createTrackingFolder(folder)
        .then(function() {

                // TODO: fs.access to test permission

            return when.promise(function(resolve, reject) {
                fs.stat(path, function(error) {
                    if (error && error.code === ENOENT && !allowDoesNotExist) {
                        reject(error);
                    } else {
                        resolve(path);
                    }
                })
            })
            .then(function(path) {
                return removeFile(path);
            });
        });
    },

    /////////////

    removeFile: function(path) {
        return when.promise(function(resolve, reject) {
            fs.unlink(path, function(error) {
                if (error) {
                    reject(error);
                } else {
                    resolve(path);
                }
            });
        });
    }
};
