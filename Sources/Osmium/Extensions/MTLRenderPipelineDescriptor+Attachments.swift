//
//  MTLRenderPipelineDescriptor+Attachments.swift
//  
//
//  Created by Artem Sechko on 26.02.2022.
//

import Metal

extension MTLRenderPipelineDescriptor {
    func applyAttachments(_ attachments: [MTLRenderPipelineColorAttachmentDescriptor]) {
        for (index, attachment) in attachments.enumerated() {
            colorAttachments[index] = attachment
        }
    }
}
