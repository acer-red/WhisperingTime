package util

import (
	"archive/zip"
	"fmt"
	"io"
	"os"
	"path/filepath"
)

/**
 * ZipDirectory 将指定的源目录压缩到目标 zip 文件。
 *
 * @param sourceDir 要压缩的目录路径 (例如 "my_folder")。目录本身会被包含在 zip 中。
 * @param outputFile 目标 .zip 文件的路径 (例如 "archive.zip")。
 * @param additionalFiles 额外需要压缩的文件列表，这些文件会被放在 zip 的根目录。
 * @return error 如果压缩过程中出现错误，则返回错误。
 */
func ZipDirectory(sourceDir, outputFile string, additionalFiles ...string) error {
	// 1. 创建目标 zip 文件
	file, err := os.Create(outputFile)
	if err != nil {
		return fmt.Errorf("无法创建 zip 文件: %w", err)
	}
	defer file.Close()

	// 2. 创建一个新的 zip.Writer
	archive := zip.NewWriter(file)
	defer archive.Close()

	// 获取源目录的基础名称，用于 zip 内的根目录
	baseDirName := filepath.Base(sourceDir)

	// 3. 遍历源目录
	//    filepath.Walk 会递归地访问 sourceDir 中的每个文件和目录
	err = filepath.Walk(sourceDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		// 4. 获取文件头信息
		header, err := zip.FileInfoHeader(info)
		if err != nil {
			return err
		}

		// 5. 计算文件在 zip 内部的相对路径
		//    这非常重要，否则 zip 文件会包含你本地的完整绝对路径
		relPath, err := filepath.Rel(sourceDir, path)
		if err != nil {
			return err
		}

		// 6. 构建 zip 内的路径，包含源目录本身
		var zipPath string
		if relPath == "." {
			// 根目录本身
			zipPath = baseDirName
		} else {
			// 子文件/目录：baseDirName/relPath
			zipPath = filepath.Join(baseDirName, relPath)
		}

		// 7. 统一使用 '/' 作为路径分隔符 (zip 规范要求)
		header.Name = filepath.ToSlash(zipPath)

		// 8. 根据是文件还是目录，设置压缩方法
		if info.IsDir() {
			header.Name += "/"        // 目录名应以 '/' 结尾
			header.Method = zip.Store // 目录只存储，不压缩
		} else {
			header.Method = zip.Deflate // 文件使用默认压缩
		}

		// 9. 将文件头写入 zip
		writer, err := archive.CreateHeader(header)
		if err != nil {
			return err
		}

		// 10. 如果是文件，则打开并拷贝文件内容
		if !info.IsDir() {
			file, err := os.Open(path)
			if err != nil {
				return err
			}
			defer file.Close()

			_, err = io.Copy(writer, file)
			if err != nil {
				return err
			}
		}

		return nil
	})

	if err != nil {
		return fmt.Errorf("遍历目录时出错: %w", err)
	}

	// 11. 添加额外的文件到 zip 根目录
	for _, additionalFile := range additionalFiles {
		err = addFileToZip(archive, additionalFile, filepath.Base(additionalFile))
		if err != nil {
			return fmt.Errorf("添加额外文件 %s 时出错: %w", additionalFile, err)
		}
	}

	return nil
}

// UnzipFile 解压zip文件到指定目录，返回解压的文件路径列表
func UnzipFile(zipPath, destDir string) ([]string, error) {
	r, err := zip.OpenReader(zipPath)
	if err != nil {
		return nil, err
	}
	defer r.Close()

	if err := os.MkdirAll(destDir, 0755); err != nil {
		return nil, err
	}

	var extractedFiles []string

	for _, f := range r.File {
		fpath := filepath.Join(destDir, f.Name)

		// 防止路径遍历攻击
		if !filepath.HasPrefix(fpath, filepath.Clean(destDir)+string(os.PathSeparator)) {
			return nil, fmt.Errorf("非法的文件路径: %s", f.Name)
		}

		if f.FileInfo().IsDir() {
			os.MkdirAll(fpath, 0755)
			continue
		}

		if err := os.MkdirAll(filepath.Dir(fpath), 0755); err != nil {
			return nil, err
		}

		outFile, err := os.OpenFile(fpath, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, f.Mode())
		if err != nil {
			return nil, err
		}

		rc, err := f.Open()
		if err != nil {
			outFile.Close()
			return nil, err
		}

		_, err = io.Copy(outFile, rc)
		outFile.Close()
		rc.Close()

		if err != nil {
			return nil, err
		}

		// 添加到已解压文件列表
		extractedFiles = append(extractedFiles, fpath)
	}

	return extractedFiles, nil
}

// addFileToZip 将单个文件添加到 zip 归档中
func addFileToZip(archive *zip.Writer, filePath, nameInZip string) error {
	file, err := os.Open(filePath)
	if err != nil {
		return err
	}
	defer file.Close()

	info, err := file.Stat()
	if err != nil {
		return err
	}

	header, err := zip.FileInfoHeader(info)
	if err != nil {
		return err
	}

	header.Name = filepath.ToSlash(nameInZip)
	header.Method = zip.Deflate

	writer, err := archive.CreateHeader(header)
	if err != nil {
		return err
	}

	_, err = io.Copy(writer, file)
	return err
}
